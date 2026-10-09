import { computed } from 'vue'
import raw from './generated/programmes.json'
import type { Level, Programme } from '@/content/types'
import { useI18n } from '@/i18n'

const all = raw as Programme[]

/** Programmes in the current language, alphabetically by local title. */
export function useProgrammes() {
  const { locale } = useI18n()
  return computed(() => all.filter((p) => p.lang === locale.value).sort((a, b) => a.title.localeCompare(b.title, locale.value)))
}

export function findProgramme(path: string): Programme | undefined {
  return all.find((p) => p.path === path)
}

export const levelOrder: Level[] = ['bachelor', 'master', 'phd', 'executive']

/** Duration in the user's language: whole years when even, else semesters. */
export function useDuration() {
  const { m } = useI18n()
  return (p: Programme): string | null => {
    if (!p.semesters) return null
    return p.semesters % 2 === 0 ? m.value.programme.years(p.semesters / 2) : m.value.programme.semesters(p.semesters)
  }
}
