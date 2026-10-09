import { describe, expect, it } from 'vitest'
import { normalize, search, type SearchEntry } from './search'

const entries: SearchEntry[] = [
  { id: '1', title: 'Artificial Intelligence', subtitle: 'Master · Informatics', group: 'Programmes', to: '/a' },
  { id: '2', title: 'Informatics', subtitle: 'Bachelor · Informatics', group: 'Programmes', to: '/b' },
  { id: '3', title: 'Faculty of Informatics', subtitle: 'Campus Lugano East', group: 'Faculties', to: '/c' },
  { id: '4', title: 'Finance', subtitle: 'Master · Economics', group: 'Programmes', to: '/d', keywords: 'banking' },
  { id: '5', title: 'Università della Svizzera italiana', subtitle: 'About', group: 'Pages', to: '/e' },
]

describe('normalize', () => {
  it('strips diacritics and case', () => {
    expect(normalize('  Università ')).toBe('universita')
  })
})

describe('search', () => {
  it('returns nothing for an empty query', () => {
    expect(search(entries, '   ')).toEqual([])
  })

  it('ranks exact and prefix title matches first', () => {
    const ids = search(entries, 'informatics').map((r) => r.id)
    expect(ids[0]).toBe('2')
    expect(ids).toContain('3')
    expect(ids).toContain('1') // matched through the subtitle
  })

  it('requires every token to match', () => {
    expect(search(entries, 'master banking').map((r) => r.id)).toEqual(['4'])
    expect(search(entries, 'finance robotics')).toEqual([])
  })

  it('ignores accents in the query and the content', () => {
    expect(search(entries, 'universita')[0]?.id).toBe('5')
  })

  it('tolerates abbreviations via subsequence matching', () => {
    expect(search(entries, 'artint').map((r) => r.id)).toEqual(['1'])
  })

  it('shows duplicate pages (same title and subtitle) once', () => {
    const dupes: SearchEntry[] = [
      { id: 'a', title: 'Borse Amici', subtitle: 'Borse', group: 'pages', to: '/it/a' },
      { id: 'b', title: 'Borse Amici', subtitle: 'Borse', group: 'pages', to: '/it/b' },
    ]
    expect(search(dupes, 'borse')).toHaveLength(1)
  })

  it('respects the limit', () => {
    expect(search(entries, 'i', 2)).toHaveLength(2)
  })
})
