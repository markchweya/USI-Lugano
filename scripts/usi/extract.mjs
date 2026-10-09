#!/usr/bin/env node
/**
 * Turns the raw HTML cached by crawl.mjs into structured, sanitised JSON.
 *
 * Outputs
 *   public/content/index.json        lightweight index of every page (search, routing)
 *   public/content/pages/<id>.json   full page: blocks, local nav, CTAs, links
 *   src/data/generated/programmes.json  degree programmes with facts parsed from text
 *   src/data/generated/events.json      event teasers seen across the site
 *   src/data/generated/stats.json       counts for the UI
 *
 * Re-runnable and offline: it never touches the network.
 */
import { createHash } from 'node:crypto'
import { mkdir, readdir, readFile, rm, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import * as cheerio from 'cheerio'
import { existsSync } from 'node:fs'
import { MEMORY, translatePage } from '../i18n/segments.mjs'

const ROOT = process.cwd()
const CACHE = join(ROOT, '.cache/usi')
const OUT_PUBLIC = join(ROOT, 'public/content')
const OUT_SRC = join(ROOT, 'src/data/generated')
const ORIGIN = 'https://www.usi.ch'

const id = (path) => createHash('sha1').update(path).digest('hex').slice(0, 12)
const clean = (s = '') => s.replace(/ /g, ' ').replace(/\s+/g, ' ').trim()

/* ------------------------------------------------------------------ */
/* Sanitiser: keeps a small, safe subset of inline/block markup.       */
/* ------------------------------------------------------------------ */

const ALLOWED = new Set(['p', 'br', 'strong', 'em', 'a', 'ul', 'ol', 'li', 'h3', 'h4', 'blockquote', 'table', 'thead', 'tbody', 'tr', 'th', 'td', 'sup', 'sub'])
const RENAME = { b: 'strong', i: 'em', h2: 'h3', h5: 'h4', h6: 'h4' }

/** Cloudflare's email obfuscation is a simple XOR with the first byte. */
function decodeCfEmail(hex) {
  const key = parseInt(hex.slice(0, 2), 16)
  let out = ''
  for (let i = 2; i < hex.length; i += 2) out += String.fromCharCode(parseInt(hex.slice(i, i + 2), 16) ^ key)
  return out
}

function normalizeHref(href = '') {
  href = href.trim()
  const cf = href.match(/\/cdn-cgi\/l\/email-protection#([0-9a-f]+)/i)
  if (cf) {
    const decoded = decodeCfEmail(cf[1])
    // Share-by-email links decode to a mailto: with a body; keep only plain addresses.
    return /^[^\s@?]+@[^\s@?]+$/.test(decoded) ? `mailto:${decoded}` : decoded.startsWith('mailto:') ? null : `mailto:${decoded}`
  }
  if (!href || href.startsWith('#')) return null
  if (/^(mailto|tel):/i.test(href)) return href
  try {
    const u = new URL(href, ORIGIN)
    if (u.origin === ORIGIN) {
      const path = decodeURI(u.pathname).replace(/\/+$/, '') || '/'
      return path + (u.hash || '')
    }
    // Only web links leave the site; anything else (javascript:, data:, ...) is dropped.
    return /^https?:$/.test(u.protocol) ? u.href : null
  } catch {
    return null
  }
}

function sanitize($, el) {
  const out = []
  const walk = (node) => {
    if (node.type === 'text') {
      out.push(escapeHtml(node.data.replace(/ /g, ' ')))
      return
    }
    if (node.type !== 'tag') return
    const name = node.name.toLowerCase()
    if (['script', 'style', 'svg', 'iframe', 'img', 'button', 'noscript', 'form', 'input'].includes(name)) return
    if ($(node).hasClass('icon_container0')) return
    const tag = RENAME[name] ?? name
    if (!ALLOWED.has(tag)) {
      node.children?.forEach(walk)
      return
    }
    if (tag === 'br') return void out.push('<br>')
    let attrs = ''
    if (tag === 'a') {
      const href = normalizeHref($(node).attr('href'))
      if (!href) return void node.children?.forEach(walk)
      attrs = ` href="${escapeHtml(href)}"`
    }
    if (tag === 'td' || tag === 'th') {
      const span = $(node).attr('colspan')
      if (span) attrs += ` colspan="${Number(span) || 1}"`
    }
    out.push(`<${tag}${attrs}>`)
    node.children?.forEach(walk)
    out.push(`</${tag}>`)
  }
  $(el).contents().each((_, n) => walk(n))
  return out
    .join('')
    .replace(/<p>\s*(<br>\s*)*<\/p>/g, '')
    .replace(/<(strong|em)>\s*<\/\1>/g, '')
    .replace(/\s+/g, ' ')
    .trim()
}

function escapeHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
}

/* ------------------------------------------------------------------ */
/* Images                                                              */
/* ------------------------------------------------------------------ */

function pickImage($, img) {
  const inter = $(img).attr('data-interchange')
  if (inter) {
    const sizes = Object.fromEntries([...inter.matchAll(/\[([^,\]]+),\s*(\w+)\]/g)].map((m) => [m[2], m[1].trim()]))
    return sizes.large ?? sizes.medium ?? sizes.xlarge ?? Object.values(sizes)[0] ?? null
  }
  const src = $(img).attr('src')
  return src && /^https?:/.test(src) ? src : src?.startsWith('/sites/') ? ORIGIN + src : null
}

function bgImage($, el) {
  const m = ($(el).attr('style') ?? '').match(/url\(['"]?([^'")]+)['"]?\)/)
  return m ? m[1] : null
}

function youtubeId(src = '') {
  const m = src.match(/youtube(?:-nocookie)?\.com\/embed\/([\w-]{6,})/)
  return m ? m[1] : null
}

/* ------------------------------------------------------------------ */
/* Block extraction                                                    */
/* ------------------------------------------------------------------ */

function extractBlocks($, root) {
  const blocks = []
  const push = (b) => blocks.push(b)

  const visit = (el) => {
    const $el = $(el)
    const tag = el.name?.toLowerCase()
    if (!tag || ['script', 'style', 'noscript', 'nav', 'form', 'button'].includes(tag)) return
    if ($el.hasClass('breadcrumb') || $el.hasClass('accordion_toggle_all') || $el.hasClass('share0') || $el.hasClass('print0')) return

    // Slider / gallery
    const slides = $el.children('.slider__element')
    if (slides.length) {
      const items = []
      slides.each((_, s) => {
        const yt = youtubeId($(s).find('iframe').attr('src'))
        const caption = clean($(s).find('.caption0').text())
        if (yt) items.push({ kind: 'video', youtube: yt, caption })
        const img = $(s).find('img').first()
        if (img.length) {
          const src = pickImage($, img)
          if (src) items.push({ kind: 'image', src, alt: clean(img.attr('alt')).replace(/\.(jpe?g|png)$/i, ''), caption })
        }
      })
      if (items.length) push({ t: 'gallery', items })
      return
    }

    // Accordion
    if (tag === 'ul' && $el.hasClass('accordion')) {
      const items = []
      $el.children('li').each((_, li) => {
        const title = clean($(li).children('a').first().text())
        const body = $(li).children('.accordion-content').first()
        const html = body.length ? sanitize($, body) : ''
        if (title && html) items.push({ title, html })
      })
      if (items.length) push({ t: 'accordion', items })
      return
    }

    // Testimonial / person card
    if ($el.attr('role') === 'group' && $el.find('.crop').length) {
      const name = clean($el.find('.font--medium').first().text())
      const role = clean($el.find('.font--medium').first().next('p').text())
      const html = sanitize($, $el.find('.text_container').first())
      push({ t: 'quote', name, role, photo: bgImage($, $el.find('.crop')[0]), html })
      return
    }

    // Card grids (study programmes, campuses, ...)
    if ($el.hasClass('study-programs') || ($el.children('.column').length > 1 && $el.find('.study_program').length)) {
      const items = []
      $el.find('.study_program').each((_, card) => {
        const a = $(card).find('a').first()
        const href = normalizeHref(a.attr('href'))
        const title = clean($(card).find('.title').text() || a.text())
        const img = $(card).find('img').first()
        if (title && href) items.push({ title, href, image: img.length ? pickImage($, img) : null })
      })
      if (items.length) {
        push({ t: 'cards', items })
        return
      }
    }

    // Event teasers are collected globally, not rendered inline.
    if ($el.hasClass('events')) return

    if ($el.hasClass('text_container')) {
      const html = sanitize($, el)
      if (html.replace(/<[^>]+>/g, '').trim()) push({ t: 'html', html })
      return
    }

    if (tag === 'h1') return
    if (/^h[2-4]$/.test(tag)) {
      const text = clean($el.text())
      if (text && !/^(expand all|espandi tutto)$/i.test(text)) push({ t: 'h', level: tag === 'h2' ? 2 : 3, text })
      return
    }

    if (tag === 'iframe') {
      const yt = youtubeId($el.attr('src'))
      if (yt) push({ t: 'video', youtube: yt, caption: '' })
      return
    }

    if (tag === 'img') {
      const src = pickImage($, el)
      if (src) push({ t: 'image', src, alt: clean($el.attr('alt')) })
      return
    }

    if (tag === 'table') {
      push({ t: 'html', html: `<table>${sanitize($, el)}</table>` })
      return
    }

    if (['p', 'ul', 'ol'].includes(tag)) {
      const html = sanitize($, el)
      if (html.replace(/<[^>]+>/g, '').trim()) push({ t: 'html', html: `<${tag}>${html}</${tag}>` })
      return
    }

    $el.children().each((_, c) => visit(c))
  }

  $(root)
    .children()
    .each((_, c) => visit(c))

  // Merge adjacent rich-text blocks and drop consecutive duplicate headings.
  const merged = []
  for (const b of blocks) {
    const prev = merged.at(-1)
    if (prev?.t === 'html' && b.t === 'html') prev.html += b.html
    else if (prev?.t === 'h' && b.t === 'h' && prev.text === b.text) continue
    else merged.push(b)
  }
  return merged
}

function extractEvents($, path) {
  const events = []
  $('.event').each((_, ev) => {
    const a = $(ev).find('a').first()
    const title = clean(a.text())
    const href = normalizeHref(a.attr('href'))
    if (!title || !href) return
    const org = clean($(ev).clone().children('p').remove().end().text())
    // Dates sit in a sibling column, before the teaser list.
    const row = $(ev).closest('.row')
    const dc = row.find('.date_container').first()
    const date = dc.length ? [clean(dc.find('.day').text()), clean(dc.find('.month').text()), clean(dc.find('.year').text())] : null
    events.push({ title, href, org, date, lang: path.slice(1, 3) })
  })
  return events
}

/* ------------------------------------------------------------------ */
/* Programme facts                                                     */
/* ------------------------------------------------------------------ */

const LEVEL_PATTERNS = [
  ['bachelor', /^\/(en\/education|it\/formazione)\/bachelor\/([^/]+)$/],
  ['master', /^\/(en\/education|it\/formazione|it\/education)\/master\/([^/]+)$/],
]

const NOT_PROGRAMMES =
  /^(bachelor-at-a-glance|bachelor-in-uno-sguardo|master-at-a-glance|panoramica-magistrali|admission|ammissione|enrolment|iscrizione|registration|contacts?|contatti|open-days?|porte-aperte|organising|organizzare|fees|tasse|why|perche|study|organise|organize|enrol|apply|faq|scholarships|ammissione-triennali|iscrizione-triennali|porte-aperte-triennali|iscrizione-magistrali|porte-aperte-orientamento|organizzare-gli-studi|.*-at-a-glance)/

const FACULTY_HINTS = [
  ['informatics', /informatic|computational|artificial intelligence|software|data science|fintech|financial technology|informatica|cyber/i],
  ['biomedical-sciences', /medicin|biomedic|oncolog|immunolog|neuroscien|biomedicina/i],
  ['architecture', /architect|architettura|accademia di architettura/i],
  ['theology', /theolog|teologi|religio/i],
  ['economics', /economi|finance|finanz|management|tourism|turismo|banking|policy/i],
  ['communication', /communicat|comunicazion|media|philosoph|filosofi|italian|italian[ao]|lingu|fashion|cultur|journalism|health/i],
]

function guessFaculty(text) {
  for (const [slug, re] of FACULTY_HINTS) if (re.test(text)) return slug
  return null
}

const NUM = { one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, due: 2, tre: 3, quattro: 4, sei: 6 }
const toNum = (v) => NUM[v.toLowerCase()] ?? Number(v)

function mostFrequent(values) {
  const counts = new Map()
  for (const v of values) counts.set(v, (counts.get(v) ?? 0) + 1)
  return [...counts.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ?? null
}

/**
 * Pulls credits, duration and teaching language out of a programme's own text
 * plus its sub-pages. Uses the most frequent plausible value so that a stray
 * mention (e.g. a Master page citing the 180 ECTS Bachelor prerequisite) loses.
 */
function programmeFacts(text, level) {
  // Only credit totals that fit the degree level count; anything else is a stray mention.
  const plausible = level === 'bachelor' ? [180] : [90, 120]
  const ectsValues = [...text.matchAll(/(\d{2,3})\s*(?:ECTS|crediti|credits)/gi)].map((m) => Number(m[1])).filter((v) => plausible.includes(v))
  const ects = mostFrequent(ectsValues)

  const durations = [...text.matchAll(/\b(\d|one|two|three|four|five|six|due|tre|quattro|sei)[\s-]+(semesters?|semestri|years?|anni)\b/gi)].map((m) =>
    /^sem/i.test(m[2]) ? toNum(m[1]) : toNum(m[1]) * 2,
  )
  const [lo, hi] = level === 'bachelor' ? [6, 8] : [2, 4]
  const fromEcts = ects ? Math.round(ects / 30) : null
  const semesters = fromEcts ?? mostFrequent(durations.filter((n) => n >= lo && n <= hi))

  const langs = new Set()
  for (const m of text.matchAll(/(taught|held|delivered|offered|language of instruction|teaching language|lingua d.insegnamento|insegnat[oi]|in lingua|entirely|fully)[^.]{0,60}?\b(english|italian|inglese|italiano)\b/gi)) {
    langs.add(/^(english|inglese)$/i.test(m[2]) ? 'EN' : 'IT')
  }
  return { ects, semesters, languages: [...langs].sort() }
}

/* ------------------------------------------------------------------ */

async function main() {
  const state = JSON.parse(await readFile(join(CACHE, 'state.json'), 'utf8'))
  const ok = Object.entries(state.pages).filter(([, p]) => p.status === 200 && p.file)

  // Update in place (rather than wiping the folder) so dev-server file watchers stay consistent.
  await mkdir(join(OUT_PUBLIC, 'pages'), { recursive: true })
  await mkdir(OUT_SRC, { recursive: true })

  const index = []
  const programmes = []
  const eventMap = new Map()
  const textByPath = new Map()
  const candidates = []
  const enPages = []
  let blockCount = 0

  for (const [path, meta] of ok) {
    const html = await readFile(join(CACHE, meta.file), 'utf8')
    const $ = cheerio.load(html)
    $('script, style, noscript').remove()
    // Cloudflare obfuscates e-mail labels too; restore the readable address.
    $('.__cf_email__[data-cfemail]').each((_, el) => {
      $(el).replaceWith(escapeHtml(decodeCfEmail($(el).attr('data-cfemail'))))
    })
    // Pagers, filter forms and screen-reader-only Drupal headings are listing chrome, not content.
    $('.pager, .pagination, .element-invisible, .visually-hidden, form').remove()

    const lang = path.startsWith('/it') ? 'it' : 'en'
    const title = clean($('.page_content h1').first().text()) || clean($('meta[property="og:title"]').attr('content')) || clean($('title').text()).replace(/\s*\|\s*USI.*$/, '')
    const description = clean($('meta[name="description"]').attr('content')).replace(/[\s|·–-]+$/, '')
    const alternates = {}
    $('link[rel="alternate"][hreflang]').each((_, el) => {
      const href = normalizeHref($(el).attr('href'))
      if (href) alternates[$(el).attr('hreflang')] = href
    })

    const crumbs = []
    $('.breadcrumb li').each((_, li) => {
      const a = $(li).find('a')
      crumbs.push({ label: clean($(li).text()), path: a.length ? normalizeHref(a.attr('href')) : null })
    })

    const mainCol = $('.page_content .large-9').first()
    const root = mainCol.length ? mainCol : $('.page_content').first()
    const blocks = root.length ? extractBlocks($, root) : []
    blockCount += blocks.length

    const sidebar = $('.page_content .sidebar').first()
    const ctas = []
    sidebar.find('.promotional_buttons a').each((_, a) => {
      const href = normalizeHref($(a).attr('href'))
      if (href) ctas.push({ label: clean($(a).text()), href })
    })
    const nav = []
    sidebar.find('.vertical_menu0 .vertical_menu > li > .section_item > a, .vertical_menu0 .vertical_menu > li a').each((_, a) => {
      const href = normalizeHref($(a).attr('href'))
      const label = clean($(a).text())
      if (href && label && !nav.some((n) => n.href === href)) nav.push({ label, href })
    })
    const links = []
    sidebar.find('.links0 a, .collection a').each((_, a) => {
      const href = normalizeHref($(a).attr('href'))
      const label = clean($(a).text())
      if (href && label && !links.some((l) => l.href === href)) links.push({ label, href })
    })

    const firstImage =
      blocks.flatMap((b) => (b.t === 'gallery' ? b.items.filter((i) => i.kind === 'image').map((i) => i.src) : b.t === 'image' ? [b.src] : b.t === 'cards' ? b.items.map((c) => c.image).filter(Boolean) : []))[0] ?? null

    const text = blocks.map((b) => (b.html ?? b.text ?? '').replace(/<[^>]+>/g, ' ')).join(' ')
    const section = crumbs[1]?.label ?? (path.split('/')[2] ?? 'home')
    const pageId = id(path)

    if (!blocks.length && !description) continue

    const entry = {
      id: pageId,
      path,
      lang,
      title,
      description: description.slice(0, 280),
      section,
      crumbs: crumbs.slice(1, -1).map((c) => c.label),
      image: firstImage,
      words: text.split(/\s+/).filter(Boolean).length,
    }
    index.push(entry)

    const full = { ...entry, alternates, breadcrumb: crumbs, blocks, ctas, nav, links, source: ORIGIN + path, fetchedAt: meta.fetchedAt }
    await writeFile(join(OUT_PUBLIC, 'pages', `${pageId}.json`), JSON.stringify(full))
    if (lang === 'en') enPages.push(full)

    for (const ev of extractEvents($, path)) {
      if (!eventMap.has(ev.href)) eventMap.set(ev.href, ev)
    }

    textByPath.set(path, `${description} ${text}`)
    for (const [level, re] of LEVEL_PATTERNS) {
      const m = path.match(re)
      if (!m || NOT_PROGRAMMES.test(m[2])) continue
      // A real programme page carries apply/open-day buttons or its own sub-navigation.
      if (!ctas.length && nav[0]?.href !== path) continue
      candidates.push({ pageId, path, lang, level, slug: m[2], title, description, text, crumbs, firstImage, ctas, alternates })
    }
  }

  for (const c of candidates) {
    const family = [...textByPath.entries()].filter(([p]) => p === c.path || p.startsWith(`${c.path}/`)).map(([, t]) => t)
    programmes.push({
      id: c.pageId,
      path: c.path,
      lang: c.lang,
      level: c.level,
      slug: c.slug,
      title: c.title.replace(/^(Bachelor|Master)( of (Science|Arts))?( in)?\s+/i, ''),
      fullTitle: c.title,
      summary: c.description || clean(c.text).slice(0, 240),
      // The title is the strongest signal; fall back to description and breadcrumbs.
      faculty: guessFaculty(c.title) ?? guessFaculty(`${c.description} ${c.crumbs.map((x) => x.label).join(' ')}`),
      image: c.firstImage,
      apply: c.ctas[0]?.href ?? null,
      ...programmeFacts(family.join(' '), c.level),
      alternates: c.alternates,
    })
  }

  // Every language keeps its own programme list; the UI shows the one for the current locale.
  const deduped = programmes
  deduped.forEach((p) => delete p.alternates)

  // German: built from the translation memory; a page appears only when fully translated.
  const memory = existsSync(MEMORY) ? JSON.parse(await readFile(MEMORY, 'utf8')) : {}
  const dePaths = new Set()
  for (const en of enPages) {
    const de = translatePage(en, memory)
    if (!de) continue
    de.id = id(de.path)
    de.alternates = { en: en.path, ...(en.alternates.it && { it: en.alternates.it }), de: de.path }
    const text = de.blocks.map((b) => (b.html ?? b.text ?? '').replace(/<[^>]+>/g, ' ')).join(' ')
    de.words = text.split(/\s+/).filter(Boolean).length
    await writeFile(join(OUT_PUBLIC, 'pages', `${de.id}.json`), JSON.stringify(de))
    const { id: deId, path, lang, title, description, section, crumbs, image, words, translated } = de
    index.push({ id: deId, path, lang, title, description: description.slice(0, 280), section, crumbs, image, words, translated })
    dePaths.add(en.path)
  }
  // German programmes mirror the English ones whose pages are translated.
  const deById = new Map(index.filter((e) => e.lang === 'de').map((e) => [e.path, e]))
  for (const p of programmes.filter((p) => p.lang === 'en' && dePaths.has(p.path))) {
    const de = deById.get(`/de${p.path.slice(3)}`)
    deduped.push({
      ...p,
      id: de.id,
      path: de.path,
      lang: 'de',
      title: de.title.replace(/^(Bachelor|Master)( of (Science|Arts))?( in)?\s+/i, ''),
      fullTitle: de.title,
      summary: de.description || p.summary,
      translated: true,
    })
  }

  // Remove page files for pages that no longer exist.
  const live = new Set(index.map((e) => `${e.id}.json`))
  for (const f of await readdir(join(OUT_PUBLIC, 'pages'))) {
    if (!live.has(f)) await rm(join(OUT_PUBLIC, 'pages', f))
  }

  index.sort((a, b) => a.path.localeCompare(b.path))
  const events = [...eventMap.values()]

  await writeFile(join(OUT_PUBLIC, 'index.json'), JSON.stringify(index))
  await writeFile(join(OUT_SRC, 'programmes.json'), JSON.stringify(deduped, null, 1))
  await writeFile(join(OUT_SRC, 'events.json'), JSON.stringify(events, null, 1))
  await writeFile(
    join(OUT_SRC, 'stats.json'),
    JSON.stringify(
      {
        pages: index.length,
        pagesEn: index.filter((p) => p.lang === 'en').length,
        pagesIt: index.filter((p) => p.lang === 'it').length,
        pagesDe: index.filter((p) => p.lang === 'de').length,
        programmes: deduped.length,
        events: events.length,
        blocks: blockCount,
        words: index.reduce((n, p) => n + p.words, 0),
        images: new Set(index.map((p) => p.image).filter(Boolean)).size,
        generatedAt: new Date().toISOString(),
      },
      null,
      2,
    ),
  )

  console.log(`pages ${index.length} · programmes ${deduped.length} · events ${events.length} · blocks ${blockCount}`)
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
