/**
 * Shared helpers for the German translation pipeline.
 *
 * A "segment" is one translatable string from an English page (a title, a
 * heading, a rich-text block…). Segments are keyed by a hash of their English
 * text, so identical strings are translated once and edits to the English
 * source naturally invalidate their old translation.
 */
import { createHash } from 'node:crypto'

export const MEMORY = 'i18n/de/memory.json'

export const segmentKey = (text) => createHash('sha1').update(text).digest('hex').slice(0, 16)

/** Every translatable string of a page, in document order. */
export function pageSegments(page) {
  const out = []
  const add = (text) => {
    if (typeof text === 'string' && text.trim() && /\p{L}/u.test(text)) out.push(text)
  }
  add(page.title)
  add(page.description)
  add(page.section)
  page.breadcrumb?.forEach((c) => add(c.label))
  for (const b of page.blocks ?? []) {
    switch (b.t) {
      case 'h':
        add(b.text)
        break
      case 'html':
        add(b.html)
        break
      case 'gallery':
        b.items.forEach((i) => {
          add(i.caption)
          add(i.alt)
        })
        break
      case 'video':
        add(b.caption)
        break
      case 'image':
        add(b.alt)
        break
      case 'accordion':
        b.items.forEach((i) => {
          add(i.title)
          add(i.html)
        })
        break
      case 'quote':
        add(b.role)
        add(b.html)
        break
      case 'cards':
        b.items.forEach((c) => add(c.title))
        break
    }
  }
  ;[...(page.ctas ?? []), ...(page.nav ?? []), ...(page.links ?? [])].forEach((l) => add(l.label))
  return out
}

/** Tag/attribute skeleton of an HTML string: translations must keep it identical. */
export function skeleton(html) {
  return [...html.matchAll(/<\/?([a-z0-9]+)((?:\s+[a-z-]+="[^"]*")*)\s*\/?>/gi)].map((m) => `${m[1].toLowerCase()}${m[2]}`).join('|')
}

/** Validates one translation against its source; returns an error string or null. */
export function checkTranslation(source, target) {
  if (typeof target !== 'string' || !target.trim()) return 'empty'
  if (skeleton(source) !== skeleton(target)) return 'markup changed'
  if (/ß/.test(target)) return 'uses ß (Swiss German uses ss)'
  const ratio = target.length / Math.max(1, source.length)
  if (source.length > 40 && (ratio < 0.5 || ratio > 2.6)) return `suspicious length ratio ${ratio.toFixed(2)}`
  return null
}

/** Returns a translated copy of a page, or null if any segment is missing. */
export function translatePage(page, memory) {
  const tr = (text) => {
    if (typeof text !== 'string' || !text.trim() || !/\p{L}/u.test(text)) return text
    const hit = memory[segmentKey(text)]
    if (hit === undefined) throw new MissingSegment()
    return hit
  }
  const toDe = (href) => (typeof href === 'string' && href.startsWith('/en/') ? `/de${href.slice(3)}` : href)
  try {
    return {
      ...page,
      path: toDe(page.path),
      lang: 'de',
      translated: true,
      title: tr(page.title),
      description: tr(page.description),
      section: tr(page.section),
      crumbs: page.crumbs.map((c) => tr(c)),
      breadcrumb: page.breadcrumb.map((c) => ({ label: tr(c.label), path: c.path })),
      blocks: page.blocks.map((b) => {
        switch (b.t) {
          case 'h':
            return { ...b, text: tr(b.text) }
          case 'html':
            return { ...b, html: tr(b.html) }
          case 'gallery':
            return { ...b, items: b.items.map((i) => ({ ...i, caption: tr(i.caption), alt: tr(i.alt) })) }
          case 'video':
            return { ...b, caption: tr(b.caption) }
          case 'image':
            return { ...b, alt: tr(b.alt) }
          case 'accordion':
            return { ...b, items: b.items.map((i) => ({ title: tr(i.title), html: tr(i.html) })) }
          case 'quote':
            return { ...b, role: tr(b.role), html: tr(b.html) }
          case 'cards':
            return { ...b, items: b.items.map((c) => ({ ...c, title: tr(c.title) })) }
          default:
            return b
        }
      }),
      ctas: page.ctas.map((l) => ({ ...l, label: tr(l.label) })),
      nav: page.nav.map((l) => ({ ...l, label: tr(l.label) })),
      links: page.links.map((l) => ({ ...l, label: tr(l.label) })),
    }
  } catch (err) {
    if (err instanceof MissingSegment) return null
    throw err
  }
}

class MissingSegment extends Error {}
