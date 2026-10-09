import { shallowRef } from 'vue'
import type { Page, PageEntry } from './types'

/*
 * The content corpus lives in /public/content and is fetched lazily, so the
 * 1,000+ real pages never bloat the JS bundle. Requests are memoised.
 */

const BASE = `${import.meta.env.BASE_URL}content`

let indexPromise: Promise<PageEntry[]> | null = null
/** Reactive so link components re-resolve once the index arrives. */
const byPath = shallowRef<Map<string, PageEntry> | null>(null)
const pageCache = new Map<string, Promise<Page>>()

export function loadIndex(): Promise<PageEntry[]> {
  indexPromise ??= fetch(`${BASE}/index.json`)
    .then((r) => {
      if (!r.ok) throw new Error(`Content index unavailable (${r.status})`)
      return r.json() as Promise<PageEntry[]>
    })
    .then((entries) => {
      byPath.value = new Map(entries.map((e) => [e.path, e]))
      return entries
    })
    .catch((err) => {
      indexPromise = null // allow a retry after a network failure
      throw err
    })
  return indexPromise
}

export async function findEntry(path: string): Promise<PageEntry | undefined> {
  await loadIndex()
  return byPath.value?.get(normalizePath(path))
}

/** Synchronous lookup — only valid once the index has loaded. */
export function isKnownPath(path: string): boolean {
  return byPath.value?.has(normalizePath(path)) ?? false
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
    // On German pages, links into the English site point at the German translation when it exists.
    if (locale === 'de' && href.startsWith('/en/')) {
      const de = `/de${href.slice(3)}`
      if (isKnownPath(de)) return { internal: true, href: de }
    }
    return isKnownPath(href) ? { internal: true, href } : { internal: false, href: `https://www.usi.ch${href}` }
  }
  return { internal: false, href }
}

/**
 * Pages to list for a locale. German is translated from English, so until a
 * page has its German version, the English page is listed at its /de path
 * (the content view shows it with an "untranslated" notice).
 */
export function entriesFor(all: PageEntry[], locale: string): PageEntry[] {
  const own = all.filter((e) => e.lang === locale)
  if (locale !== 'de') return own
  const have = new Set(own.map((e) => e.path))
  const pending = all
    .filter((e) => e.lang === 'en' && !have.has(`/de${e.path.slice(3)}`))
    .map((e) => ({ ...e, path: `/de${e.path.slice(3)}`, untranslated: true }))
  return [...own, ...pending]
}
