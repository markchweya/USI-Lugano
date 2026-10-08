export interface SearchEntry {
  id: string
  title: string
  subtitle: string
  group: string
  to: string
  /** Extra text that should match but is not displayed. */
  keywords?: string
}

export interface SearchResult extends SearchEntry {
  score: number
}

export function normalize(text: string): string {
  return text.normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase().trim()
}

/** True when every character of `needle` appears in `haystack` in order. */
function isSubsequence(needle: string, haystack: string): boolean {
  let i = 0
  for (const ch of haystack) {
    if (ch === needle[i]) i++
    if (i === needle.length) return true
  }
  return needle.length === 0
}

function scoreToken(token: string, title: string, words: string[], rest: string): number {
  if (words.some((w) => w.startsWith(token))) return 10
  if (title.includes(token)) return 6
  if (rest.includes(token)) return 3
  if (token.length >= 3 && isSubsequence(token, title)) return 1
  return 0
}

/**
 * Ranks entries against a free-text query. Every token must match somewhere;
 * matches at word starts in the title beat substring matches, which beat
 * matches in the subtitle/keywords, which beat fuzzy subsequence matches.
 */
export function search(entries: SearchEntry[], query: string, limit = 20): SearchResult[] {
  const q = normalize(query)
  if (!q) return []
  const tokens = q.split(/\s+/)

  const results: SearchResult[] = []
  for (const entry of entries) {
    const title = normalize(entry.title)
    const words = title.split(/[^\p{L}\p{N}]+/u)
    const rest = normalize(`${entry.subtitle} ${entry.keywords ?? ''}`)

    let score = 0
    for (const token of tokens) {
      const s = scoreToken(token, title, words, rest)
      if (s === 0) {
        score = 0
        break
      }
      score += s
    }
    if (score === 0) continue
    if (title.startsWith(q)) score += 15
    if (title === q) score += 10
    results.push({ ...entry, score })
  }

  return results.sort((a, b) => b.score - a.score || a.title.localeCompare(b.title)).slice(0, limit)
}
