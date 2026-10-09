import { computed, shallowRef } from 'vue'
import { entriesFor, loadIndex } from './api'
import type { PageEntry } from './types'
import { useI18n, type Locale } from '@/i18n'

export type SectionKey = 'education' | 'research' | 'innovation' | 'university'

/** Section roots per language: Italian uses usi.ch's own Italian paths, German mirrors English. */
const roots: Record<SectionKey, Record<Locale, string>> = {
  education: { en: '/en/education', it: '/it/formazione', de: '/de/education' },
  research: { en: '/en/research', it: '/it/ricerca', de: '/de/research' },
  innovation: { en: '/en/innovation', it: '/it/innovazione', de: '/de/innovation' },
  university: { en: '/en/university', it: '/it/universita', de: '/de/university' },
}

export const sectionKeys: SectionKey[] = ['education', 'research', 'innovation', 'university']

export function sectionOf(path: string): SectionKey | 'other' {
  return sectionKeys.find((k) => Object.values(roots[k]).some((r) => path === r || path.startsWith(`${r}/`))) ?? 'other'
}

const entries = shallowRef<PageEntry[]>([])
let started = false
const depth = (p: string) => p.split('/').length

/** Navigation discovered from the real content index, in the current language. */
export function useSiteNav() {
  const { locale, m } = useI18n()
  if (!started) {
    started = true
    loadIndex()
      .then((e) => (entries.value = e))
      .catch(() => {
        started = false
      })
  }

  const localEntries = computed(() => entriesFor(entries.value, locale.value))

  const sections = computed(() =>
    sectionKeys.map((key) => ({ key, root: roots[key][locale.value], label: m.value.sections[key].label, blurb: m.value.sections[key].blurb })),
  )

  const children = computed(() => {
    const map = {} as Record<SectionKey, PageEntry[]>
    for (const s of sections.value) {
      map[s.key] = localEntries.value
        .filter((e) => e.path.startsWith(`${s.root}/`) && depth(e.path) === depth(s.root) + 1)
        .sort((a, b) => a.title.localeCompare(b.title, locale.value))
    }
    return map
  })

  return { sections, children, entries: localEntries, count: computed(() => localEntries.value.length) }
}
