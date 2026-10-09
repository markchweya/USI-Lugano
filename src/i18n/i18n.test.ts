import { describe, expect, it } from 'vitest'
import { appPageOf, appPath, detectLocale, localeFromPath, messages, locales } from './index'

describe('locale helpers', () => {
  it('detects the best supported locale from browser preferences', () => {
    expect(detectLocale(['de-CH', 'en'])).toBe('de')
    expect(detectLocale(['fr-CH', 'it-CH'])).toBe('it')
    expect(detectLocale(['fr-FR'])).toBe('en')
  })

  it('reads the locale from a path', () => {
    expect(localeFromPath('/it/formazione')).toBe('it')
    expect(localeFromPath('/fr/x')).toBeNull()
  })

  it('round-trips localised app paths', () => {
    for (const l of locales) {
      for (const page of ['home', 'study', 'explore'] as const) {
        expect(appPageOf(appPath(page, l))).toBe(page)
      }
    }
    expect(appPath('study', 'de')).toBe('/de/studiengaenge')
    expect(appPageOf('/en/education/master')).toBeNull()
  })
})

describe('dictionaries', () => {
  // Collect every leaf path so a translation that silently equals an empty
  // string (except intentionally blank fields) is caught.
  const leaves = (obj: object, prefix = ''): [string, unknown][] =>
    Object.entries(obj).flatMap(([k, v]) => (v && typeof v === 'object' ? leaves(v, `${prefix}${k}.`) : [[`${prefix}${k}`, v]]))

  const optionalBlank = new Set(['sections.other.blurb', 'page.translatedNotice', 'page.translatedFrom'])

  it('has the same keys in every language', () => {
    const keys = (l: (typeof locales)[number]) => leaves(messages[l]).map(([k]) => k).sort()
    expect(keys('it')).toEqual(keys('en'))
    expect(keys('de')).toEqual(keys('en'))
  })

  it('has no empty strings except the documented ones', () => {
    for (const l of locales) {
      for (const [k, v] of leaves(messages[l])) {
        if (typeof v === 'string' && !optionalBlank.has(k)) expect(v.trim(), `${l}:${k}`).not.toBe('')
      }
    }
  })

  it('German uses Swiss spelling (no ß)', () => {
    for (const [k, v] of leaves(messages.de)) {
      if (typeof v === 'string') expect(v.includes('ß'), k).toBe(false)
    }
  })
})
