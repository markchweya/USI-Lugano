import { computed, shallowRef } from 'vue'
import { loadIndex } from './api'
import type { PageEntry } from './types'

export interface NavSection {
  key: string
  label: string
  root: string
  blurb: string
}

/** Top-level areas of usi.ch, in the order a prospective student cares about them. */
export const sections: NavSection[] = [
  { key: 'education', label: 'Study', root: '/en/education', blurb: 'Bachelor, Master, PhD and continuing education.' },
  { key: 'research', label: 'Research', root: '/en/research', blurb: 'Institutes, projects and research support.' },
  { key: 'innovation', label: 'Innovation', root: '/en/innovation', blurb: 'Start-ups, technology transfer and partnerships.' },
  { key: 'university', label: 'University', root: '/en/university', blurb: 'Who we are, campuses, services and practical info.' },
]

const entries = shallowRef<PageEntry[]>([])
let started = false

const depth = (p: string) => p.split('/').length

/** Children one level below each section root, discovered from the real content index. */
export function useSiteNav() {
  if (!started) {
    started = true
    loadIndex()
      .then((e) => (entries.value = e))
      .catch(() => {
        started = false
      })
  }

  const children = computed(() => {
    const map: Record<string, PageEntry[]> = {}
    for (const s of sections) {
      map[s.key] = entries.value
        .filter((e) => e.path.startsWith(`${s.root}/`) && depth(e.path) === depth(s.root) + 1)
        .sort((a, b) => a.title.localeCompare(b.title))
    }
    return map
  })

  const count = computed(() => entries.value.length)

  return { sections, children, count, entries }
}
