import { loadIndex } from '@/content/api'
import { levelLabels, programmes } from '@/data/programmes'
import { getFaculty } from '@/data/faculties'
import type { SearchEntry } from './search'

const shortcuts: SearchEntry[] = [
  { id: 'go-study', title: 'Find a programme', subtitle: 'Every Bachelor and Master at USI', group: 'Go to', to: '/study', keywords: 'study degree course apply' },
  { id: 'go-explore', title: 'Explore all pages', subtitle: 'Browse the whole university by topic', group: 'Go to', to: '/explore', keywords: 'sitemap directory index' },
  { id: 'go-home', title: 'Home', subtitle: 'Start page', group: 'Go to', to: '/' },
]

const programmeEntries: SearchEntry[] = programmes.map((p) => ({
  id: `prog-${p.id}`,
  title: p.fullTitle,
  subtitle: [levelLabels[p.level], getFaculty(p.faculty)?.short].filter(Boolean).join(' · '),
  group: 'Programmes',
  to: p.path,
  keywords: `${p.summary} ${p.languages.join(' ')}`,
}))

let built: Promise<SearchEntry[]> | null = null

/** Shortcuts + programmes immediately; the full 1,000+ page corpus once fetched. */
export function buildSearchIndex(): Promise<SearchEntry[]> {
  built ??= loadIndex()
    .then((pages) => {
      const programmePaths = new Set(programmes.map((p) => p.path))
      const pageEntries = pages
        .filter((p) => !programmePaths.has(p.path))
        .map<SearchEntry>((p) => ({
          id: p.id,
          title: p.title,
          subtitle: [p.lang === 'it' ? 'Italiano' : null, ...p.crumbs].filter(Boolean).join(' › ') || p.section,
          group: 'Pages',
          to: p.path,
          keywords: p.description,
        }))
      return [...shortcuts, ...programmeEntries, ...pageEntries]
    })
    .catch(() => {
      built = null
      return [...shortcuts, ...programmeEntries]
    })
  return built
}

export const instantEntries = [...shortcuts, ...programmeEntries]
