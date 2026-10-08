import raw from './generated/programmes.json'
import type { Level, Programme } from '@/content/types'

export const programmes = (raw as Programme[]).slice().sort((a, b) => a.title.localeCompare(b.title))

export const levelLabels: Record<Level, string> = {
  bachelor: 'Bachelor',
  master: 'Master',
  phd: 'PhD',
  executive: 'Executive',
}

export function formatDuration(p: Programme): string | null {
  if (!p.semesters) return null
  const years = p.semesters / 2
  return years >= 1 ? `${years} ${years === 1 ? 'year' : 'years'}` : `${p.semesters} semester`
}
