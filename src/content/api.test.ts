import { describe, expect, it } from 'vitest'
import { entriesFor, langOfPath, normalizePath } from './api'
import type { PageEntry } from './types'

const e = (path: string, lang: PageEntry['lang'], extra: Partial<PageEntry> = {}): PageEntry => ({
  id: path,
  path,
  lang,
  title: path,
  description: '',
  section: '',
  crumbs: [],
  image: null,
  words: 1,
  ...extra,
})

describe('entriesFor', () => {
  it('keeps pages under the locale prefix only', () => {
    const all = [e('/en/a', 'en'), e('/it/a', 'it'), e('/de/a', 'de')]
    expect(entriesFor(all, 'en').map((x) => x.path)).toEqual(['/en/a'])
    expect(entriesFor(all, 'it').map((x) => x.path)).toEqual(['/it/a'])
  })

  it('keeps untranslated English pages listed at their German path', () => {
    const de = [e('/de/a', 'de', { translated: true }), e('/de/b', 'en', { untranslated: true })]
    expect(entriesFor(de, 'de').map((x) => x.path)).toEqual(['/de/a', '/de/b'])
  })
})

describe('path helpers', () => {
  it('derives the content language from a path', () => {
    expect(langOfPath('/it/formazione')).toBe('it')
    expect(langOfPath('/de/education')).toBe('de')
    expect(langOfPath('/en/x')).toBe('en')
  })

  it('normalises trailing slashes, queries and hashes', () => {
    expect(normalizePath('/en/x/?a=1#b')).toBe('/en/x')
    expect(normalizePath('/')).toBe('/')
  })
})
