import { entriesFor, loadIndex } from '@/content/api'
import raw from '@/data/generated/programmes.json'
import type { Programme } from '@/content/types'
import { appPath, messages, type Locale } from '@/i18n'
import type { SearchEntry } from './search'

const programmes = raw as Programme[]

function instant(locale: Locale): SearchEntry[] {
  const m = messages[locale]
  const s = m.palette.shortcuts
  return [
    { id: 'go-study', title: s.study.title, subtitle: s.study.subtitle, group: 'goto', to: appPath('study', locale), keywords: 'study degree course apply studio corso studium' },
    { id: 'go-explore', title: s.explore.title, subtitle: s.explore.subtitle, group: 'goto', to: appPath('explore', locale), keywords: 'sitemap directory index' },
    { id: 'go-home', title: s.home.title, subtitle: s.home.subtitle, group: 'goto', to: appPath('home', locale) },
    ...programmes
      .filter((p) => p.lang === locale)
      .map<SearchEntry>((p) => ({
        id: `prog-${p.id}`,
        title: p.fullTitle,
        subtitle: [m.levels[p.level], p.faculty ? m.faculties[p.faculty as keyof typeof m.faculties]?.short : null].filter(Boolean).join(' · '),
        group: 'programmes',
        to: p.path,
        keywords: `${p.summary} ${p.languages.join(' ')}`,
      })),
  ]
}

const built = new Map<Locale, Promise<SearchEntry[]>>()

/** Shortcuts + programmes immediately; the full corpus for this language once fetched. */
export function instantEntries(locale: Locale): SearchEntry[] {
  return instant(locale)
}

export function buildSearchIndex(locale: Locale): Promise<SearchEntry[]> {
  let p = built.get(locale)
  if (!p) {
    const base = instant(locale)
    p = loadIndex(locale)
      .then((pages) => {
        const programmePaths = new Set(programmes.map((x) => x.path))
        return [
          ...base,
          ...entriesFor(pages, locale)
            .filter((e) => !programmePaths.has(e.path))
            .map<SearchEntry>((e) => ({
              id: e.id,
              title: e.title,
              subtitle: e.crumbs.join(' › ') || e.section,
              group: 'pages',
              to: e.path,
              keywords: e.description,
            })),
        ]
      })
      .catch(() => {
        built.delete(locale)
        return base
      })
    built.set(locale, p)
  }
  return p
}
