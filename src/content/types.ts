/** Shapes produced by scripts/usi/extract.mjs. */

export type Lang = 'en' | 'it'

export interface PageEntry {
  id: string
  path: string
  lang: Lang
  title: string
  description: string
  section: string
  crumbs: string[]
  image: string | null
  words: number
}

export interface GalleryItem {
  kind: 'image' | 'video'
  src?: string
  youtube?: string
  alt?: string
  caption: string
}

export interface Card {
  title: string
  href: string
  image: string | null
}

export type Block =
  | { t: 'h'; level: 2 | 3; text: string }
  | { t: 'html'; html: string }
  | { t: 'gallery'; items: GalleryItem[] }
  | { t: 'accordion'; items: { title: string; html: string }[] }
  | { t: 'quote'; name: string; role: string; photo: string | null; html: string }
  | { t: 'cards'; items: Card[] }
  | { t: 'video'; youtube: string; caption: string }
  | { t: 'image'; src: string; alt: string }

export interface Link {
  label: string
  href: string
}

export interface Page extends PageEntry {
  alternates: Partial<Record<Lang, string>>
  breadcrumb: { label: string; path: string | null }[]
  blocks: Block[]
  ctas: Link[]
  nav: Link[]
  links: Link[]
  source: string
  fetchedAt: string
}

export type Level = 'bachelor' | 'master' | 'phd' | 'executive'

export interface Programme {
  id: string
  path: string
  lang: Lang
  level: Level
  slug: string
  title: string
  fullTitle: string
  summary: string
  faculty: string | null
  image: string | null
  apply: string | null
  ects: number | null
  semesters: number | null
  languages: ('EN' | 'IT')[]
}

export interface EventTeaser {
  title: string
  href: string
  org: string
  date: [string, string, string] | null
  lang: Lang
}

export interface ContentStats {
  pages: number
  pagesEn: number
  pagesIt: number
  programmes: number
  events: number
  blocks: number
  words: number
  images: number
  generatedAt: string
}
