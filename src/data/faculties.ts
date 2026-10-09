import type { ArtVariant } from '@/types'
import { useI18n } from '@/i18n'

export type FacultySlug = 'architecture' | 'biomedical-sciences' | 'communication' | 'economics' | 'informatics' | 'theology'

/** Visual identity per faculty; names come from the i18n dictionaries. */
export interface FacultyStyle {
  slug: FacultySlug
  color: string
  art: ArtVariant
}

export const faculties: FacultyStyle[] = [
  { slug: 'architecture', color: 'var(--fac-architecture)', art: 'grid' },
  { slug: 'biomedical-sciences', color: 'var(--fac-biomedical)', art: 'cells' },
  { slug: 'communication', color: 'var(--fac-communication)', art: 'waves' },
  { slug: 'economics', color: 'var(--fac-economics)', art: 'bars' },
  { slug: 'informatics', color: 'var(--fac-informatics)', art: 'nodes' },
  { slug: 'theology', color: 'var(--fac-theology)', art: 'arches' },
]

const bySlug = new Map(faculties.map((f) => [f.slug, f]))

export function getFaculty(slug: string | null | undefined): FacultyStyle | undefined {
  return slug ? bySlug.get(slug as FacultySlug) : undefined
}

/** Faculty style + localised name and short name. */
export function useFaculties() {
  const { m } = useI18n()
  const named = (f: FacultyStyle) => ({ ...f, ...m.value.faculties[f.slug] })
  return {
    list: () => faculties.map(named),
    get: (slug: string | null | undefined) => {
      const f = getFaculty(slug)
      return f ? named(f) : undefined
    },
  }
}
