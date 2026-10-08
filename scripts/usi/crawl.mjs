#!/usr/bin/env node
/**
 * Polite crawler for public www.usi.ch content.
 *
 * - Honours robots.txt (disallow rules + the 10s Crawl-delay).
 * - Crawls the English site breadth-first, then Italian sitemap pages that
 *   have no English counterpart.
 * - Never retries bot-protection challenges: those pages are recorded as
 *   blocked and skipped.
 * - Resumable: raw HTML is cached in .cache/usi; re-running continues.
 *
 * Usage: node scripts/usi/crawl.mjs [--max 1400] [--delay 10000]
 * (Requires NODE_USE_ENV_PROXY=1 when running behind an HTTPS proxy.)
 */
import { createHash } from 'node:crypto'
import { existsSync } from 'node:fs'
import { mkdir, readFile, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import * as cheerio from 'cheerio'

const ORIGIN = 'https://www.usi.ch'
const CACHE = join(process.cwd(), '.cache/usi')
const STATE = join(CACHE, 'state.json')
const UA = 'USI-redesign-content-sync/0.1 (+https://github.com/markchweya/usi-lugano)'

const args = Object.fromEntries(
  process.argv.slice(2).reduce((acc, a, i, all) => (a.startsWith('--') ? [...acc, [a.slice(2), all[i + 1]]] : acc), []),
)
const MAX_PAGES = Number(args.max ?? 1400)
let delay = Number(args.delay ?? 10_000)

const SKIP = [
  /^\/(en|it)\/(feeds|node|originalnode|search|search-results|page-section)\b/,
  /\/(test|prova)[-\w]*$/,
  /^\/cdn-cgi\//,
  /\.(pdf|jpe?g|png|gif|svg|zip|docx?|xlsx?|pptx?|mp4|ics)$/i,
]

const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
const hash = (s) => createHash('sha1').update(s).digest('hex').slice(0, 16)

function normalizePath(href, base = ORIGIN) {
  try {
    const u = new URL(href, base)
    if (u.origin !== ORIGIN) return null
    const path = decodeURI(u.pathname).replace(/\/+$/, '') || '/'
    if (!/^\/(en|it)(\/|$)/.test(path)) return null
    if (SKIP.some((re) => re.test(path))) return null
    return path
  } catch {
    return null
  }
}

async function loadRobots() {
  const res = await fetch(`${ORIGIN}/robots.txt`, { headers: { 'user-agent': UA } })
  const text = await res.text()
  const disallow = []
  let applies = false
  for (const raw of text.split('\n')) {
    const line = raw.replace(/#.*/, '').trim()
    const [k, ...rest] = line.split(':')
    const v = rest.join(':').trim()
    if (/^user-agent$/i.test(k)) applies = v === '*'
    else if (applies && /^disallow$/i.test(k) && v) disallow.push(v)
    else if (applies && /^crawl-delay$/i.test(k)) delay = Math.max(delay, Number(v) * 1000)
  }
  return (path) =>
    !disallow.some((rule) => {
      const pattern = '^' + rule.replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '.*')
      return new RegExp(pattern).test(path) || new RegExp(pattern).test(path + '/')
    })
}

async function sitemapPaths() {
  const out = []
  for (const page of [1, 2, 3]) {
    const res = await fetch(`${ORIGIN}/it/sitemap.xml?page=${page}`, { headers: { 'user-agent': UA } })
    if (!res.ok) break
    const xml = await res.text()
    const locs = [...xml.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => normalizePath(m[1]))
    if (!locs.length) break
    out.push(...locs.filter(Boolean))
    await sleep(delay)
  }
  return [...new Set(out)]
}

async function main() {
  await mkdir(CACHE, { recursive: true })
  const state = existsSync(STATE)
    ? JSON.parse(await readFile(STATE, 'utf8'))
    : { pages: {}, queue: ['/en'], itQueue: null, covered: [] }
  const covered = new Set(state.covered)
  const seen = new Set([...Object.keys(state.pages), ...state.queue, ...(state.itQueue ?? [])])

  const allowed = await loadRobots()
  console.log(`crawl-delay ${delay}ms, ${Object.keys(state.pages).length} pages cached`)

  const save = () => writeFile(STATE, JSON.stringify({ ...state, covered: [...covered] }))
  const fetched = () => Object.values(state.pages).filter((p) => p.status === 200).length

  while (fetched() < MAX_PAGES) {
    let path = state.queue.shift()
    if (!path) {
      if (state.itQueue === null) {
        console.log('English site exhausted — loading Italian sitemap')
        state.itQueue = (await sitemapPaths()).filter((p) => p.startsWith('/it/'))
        state.itQueue.forEach((p) => seen.add(p))
      }
      path = state.itQueue.shift()
      while (path && covered.has(path)) path = state.itQueue.shift()
      if (!path) break
    }
    if (state.pages[path] || !allowed(path)) continue

    const url = ORIGIN + encodeURI(path)
    let res
    try {
      res = await fetch(url, { headers: { 'user-agent': UA, 'accept-language': 'en' }, redirect: 'follow', signal: AbortSignal.timeout(30_000) })
    } catch (err) {
      console.warn(`network error ${path}: ${err.message}`)
      state.queue.push(path)
      await sleep(delay * 3)
      continue
    }

    let body
    try {
      body = await res.text()
    } catch (err) {
      console.warn(`body read failed ${path}: ${err.message}`)
      state.queue.push(path)
      await sleep(delay * 3)
      continue
    }
    const challenged = res.status === 403 && /Just a moment/i.test(body)
    const entry = { status: challenged ? 'blocked' : res.status, finalUrl: res.url, fetchedAt: new Date().toISOString() }

    if (res.status === 429 || res.status >= 500) {
      console.warn(`${res.status} on ${path} — backing off`)
      state.queue.push(path)
      await sleep(delay * 6)
      continue
    }

    if (res.ok) {
      const file = `${hash(path)}.html`
      await writeFile(join(CACHE, file), body)
      entry.file = file

      const $ = cheerio.load(body)
      $('link[rel="alternate"][hreflang]').each((_, el) => {
        const alt = normalizePath($(el).attr('href') ?? '')
        if (alt) covered.add(alt)
      })
      if (path.startsWith('/en')) {
        $('a[href]').each((_, el) => {
          const next = normalizePath($(el).attr('href') ?? '', url)
          if (next && next.startsWith('/en') && !seen.has(next)) {
            seen.add(next)
            state.queue.push(next)
          }
        })
      }
    }

    state.pages[path] = entry
    const n = fetched()
    console.log(`[${n}/${MAX_PAGES}] ${entry.status} ${path}  (queue ${state.queue.length}${state.itQueue ? ` + it ${state.itQueue.length}` : ''})`)
    if (n % 10 === 0) await save()
    await sleep(delay)
  }

  await save()
  console.log(`done: ${fetched()} pages`)
}

main().catch((err) => {
  console.error(err)
  process.exit(1)
})
