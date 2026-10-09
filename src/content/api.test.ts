import { describe, expect, it } from 'vitest'
import { entriesFor } from './api'
import type { PageEntry } from './types'

const e = (path: string, lang: PageEntry['lang']): PageEntry => ({ id: path, path, lang, title: path, description: '', section: '', crumbs: [], image: null, words: 1 })

describe('entriesFor', () => {
  const all = [e('/en/a', 'en'), e('/en/b', 'en'), e('/it/a', 'it'), e('/de/a', 'de')]

  it('returns only the locale’s own pages for en and it', () => {
    expect(entriesFor(all, 'en').map((x) => x.path)).toEqual(['/en/a', '/en/b'])
    expect(entriesFor(all, 'it').map((x) => x.path)).toEqual(['/it/a'])
  })

  it('fills German gaps with English pages at their /de path', () => {
    const de = entriesFor(all, 'de')
    expect(de.map((x) => x.path)).toEqual(['/de/a', '/de/b'])
    expect(de.find((x) => x.path === '/de/b')?.untranslated).toBe(true)
    expect(de.find((x) => x.path === '/de/a')?.untranslated).toBeUndefined()
  })
})
