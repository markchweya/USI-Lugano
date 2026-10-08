import type { ArtVariant } from '@/types'

/** Visual identity for USI's six faculties (names as published on usi.ch). */
export interface FacultyStyle {
  slug: string
  name: string
  short: string
  color: string
  art: ArtVariant
}

export const faculties: FacultyStyle[] = [
  { slug: 'architecture', name: 'Academy of Architecture', short: 'Architecture', color: 'var(--fac-architecture)', art: 'grid' },
  { slug: 'biomedical-sciences', name: 'Faculty of Biomedical Sciences', short: 'Biomedical Sciences', color: 'var(--fac-biomedical)', art: 'cells' },
  { slug: 'communication', name: 'Faculty of Communication, Culture and Society', short: 'Communication, Culture & Society', color: 'var(--fac-communication)', art: 'waves' },
  { slug: 'economics', name: 'Faculty of Economics', short: 'Economics', color: 'var(--fac-economics)', art: 'bars' },
  { slug: 'informatics', name: 'Faculty of Informatics', short: 'Informatics', color: 'var(--fac-informatics)', art: 'nodes' },
  { slug: 'theology', name: 'Facoltà di Teologia di Lugano (affiliated)', short: 'Theology', color: 'var(--fac-theology)', art: 'arches' },
]

const bySlug = new Map(faculties.map((f) => [f.slug, f]))

export function getFaculty(slug: string | null | undefined): FacultyStyle | undefined {
  return slug ? bySlug.get(slug) : undefined
}
