import { shallowRef } from 'vue'
import type { Page, PageEntry } from './types'

/*
 * The content corpus lives in /public/content and is fetched lazily, so the
 * thousands of real pages never bloat the JS bundle. Each language has its own
 * small index (index.<lang>.json); requests are memoised.
 */

const BASE = `${import.meta.env.BASE_URL}content`
export type ContentLang = 'en' | 'it' | 'de'

const indexPromises = new Map<ContentLang, Promise<PageEntry[]>>()
/** Every entry from the indexes loaded so far, by path. Reactive so links re-resolve. */
const byPath = shallowRef<Map<string, PageEntry>>(new Map())
const pageCache = new Map<string, Promise<Page>>()

export function langOfPath(path: string): ContentLang {
  const seg = path.split('/')[1]
  return seg === 'it' || seg === 'de' ? seg : 'en'
}

export function loadIndex(lang: ContentLang): Promise<PageEntry[]> {
  let p = indexPromises.get(lang)
  if (!p) {
    p = fetch(`${BASE}/index.${lang}.json`)
      .then((r) => {
        if (!r.ok) throw new Error(`Content index unavailable (${r.status})`)
        return r.json() as Promise<PageEntry[]>
      })
      .then((entries) => {
        const next = new Map(byPath.value)
        for (const e of entries) next.set(e.path, e)
        byPath.value = next
        return entries
      })
      .catch((err) => {
        indexPromises.delete(lang) // allow a retry after a network failure
        throw err
      })
    indexPromises.set(lang, p)
  }
  return p
}

export async function findEntry(path: string): Promise<PageEntry | undefined> {
  const clean = normalizePath(path)
  await loadIndex(langOfPath(clean))
  return byPath.value.get(clean)
}

/** Synchronous lookup — only valid once the relevant index has loaded. */
export function isKnownPath(path: string): boolean {
  return byPath.value.has(normalizePath(path))
}

export function loadPage(id: string): Promise<Page> {
  let p = pageCache.get(id)
  if (!p) {
    p = fetch(`${BASE}/pages/${id}.json`).then((r) => {
      if (!r.ok) throw new Error(`Page ${id} unavailable (${r.status})`)
      return r.json() as Promise<Page>
    })
    p.catch(() => pageCache.delete(id))
    pageCache.set(id, p)
  }
  return p
}

export function normalizePath(path: string): string {
  const clean = decodeURI(path.split(/[?#]/)[0] ?? '').replace(/\/+$/, '')
  return clean || '/'
}

/** Links inside real content: internal pages we have become app routes, the rest go to usi.ch. */
export function resolveHref(href: string, locale?: string): { internal: boolean; href: string } {
  if (href.startsWith('/')) {
    // On German pages, links into the English site point at the German version (translated or not).
    if (locale === 'de' && href.startsWith('/en/')) {
      const de = `/de${href.slice(3)}`
      if (isKnownPath(de)) return { internal: true, href: de }
    }
    return isKnownPath(href) ? { internal: true, href } : { internal: false, href: `https://www.usi.ch${href}` }
  }
  return { internal: false, href }
}

/**
 * Pages to list for a locale: everything under its prefix. The German index
 * also contains English pages awaiting translation, listed at their /de path
 * and flagged `untranslated`.
 */
export function entriesFor(all: PageEntry[], locale: string): PageEntry[] {
  return all.filter((e) => e.path === `/${locale}` || e.path.startsWith(`/${locale}/`))
}
