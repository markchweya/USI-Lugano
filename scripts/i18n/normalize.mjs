#!/usr/bin/env node
/**
 * Terminology normalisation for the German translation memory.
 *
 * Translations are produced in parallel batches, so the same office or body
 * can come out under different names. These rules enforce one name each (see
 * the terminology section of i18n/de/STYLEGUIDE.md). They only touch text
 * between HTML tags, never tags or URLs, and are idempotent, so the script
 * can run after every import.
 *
 * Rule order matters: genitive forms ("des … Service") are rewritten before
 * the plain name, because German adds -es to the translated noun.
 */
import { readFile, writeFile } from 'node:fs/promises'
import { MEMORY } from './segments.mjs'

/** [pattern, replacement] pairs, applied in order to text outside tags. */
export const RULES = [
  // Student body: one name (both feminine, so articles are unaffected).
  [/Studierendenkorporation/g, 'Studierendenschaft'],

  // English office names → German, genitive first.
  [/des(\s+)(?:USI\s+)?International Relations and Study Abroad Service/g, 'des$1Dienstes für Internationale Beziehungen und Auslandstudium'],
  [/des(\s+)(?:USI\s+)?International Relations Service/g, 'des$1Dienstes für Internationale Beziehungen'],
  [/des(\s+)(?:USI\s+)?Equal Opportunities Service/g, 'des$1Dienstes für Chancengleichheit'],
  [/des(\s+)(?:USI\s+)?Research and Transfer Service/g, 'des$1Dienstes für Forschung und Wissenstransfer'],
  [/des(\s+)(?:USI\s+)?Research Service/g, 'des$1Forschungsdienstes'],
  [/des(\s+)(?:USI\s+)?Housing Service/g, 'des$1Wohnungsdienstes'],
  [/des(\s+)(?:USI\s+)?Institutional Communication Service/g, 'des$1Dienstes für institutionelle Kommunikation'],
  [/des(\s+)(?:USI\s+)?Quality Assurance and Sustainability Service/g, 'des$1Dienstes für Qualitätssicherung und Nachhaltigkeit'],
  [/(?:USI\s+)?International Relations and Study Abroad Service/g, 'Dienst für Internationale Beziehungen und Auslandstudium'],
  [/(?:USI\s+)?International Relations Service/g, 'Dienst für Internationale Beziehungen'],
  [/(?:USI\s+)?Equal Opportunities Service/g, 'Dienst für Chancengleichheit'],
  [/(?:USI\s+)?Research and Transfer Service/g, 'Dienst für Forschung und Wissenstransfer'],
  [/(?:USI\s+)?Research Service/g, 'Forschungsdienst'],
  [/(?:USI\s+)?Housing Service/g, 'Wohnungsdienst'],
  [/(?:USI\s+)?Institutional Communication Service/g, 'Dienst für institutionelle Kommunikation'],
  [/(?:USI\s+)?Quality Assurance and Sustainability Service/g, 'Dienst für Qualitätssicherung und Nachhaltigkeit'],

  [/Gleichstellungsdienstes/g, 'Dienstes für Chancengleichheit'],
  [/Gleichstellungsdienst/g, 'Dienst für Chancengleichheit'],

  // "Dienststelle" (feminine) → "Dienst" (masculine): fix the article/case with it.
  [/\bDie Dienststelle (für|Qualitätssicherung)/g, (_, w) => `Der Dienst ${w === 'für' ? 'für' : 'für Qualitätssicherung'}`],
  [/\bdie Dienststelle (für|Qualitätssicherung)/g, (_, w) => `der Dienst ${w === 'für' ? 'für' : 'für Qualitätssicherung'}`],
  [/\bder Dienststelle (für|Qualitätssicherung)/g, (_, w) => `dem Dienst ${w === 'für' ? 'für' : 'für Qualitätssicherung'}`],
  [/\bDie Dienststelle fördert/g, 'Der Dienst fördert'],
  [/\bDienststelle für /g, 'Dienst für '],
  [/\bDienststelle Qualitätssicherung/g, 'Dienst für Qualitätssicherung'],

  // Generic public employers in career listings read in German; place names use German exonyms.
  [/\bAmministrazione federale\b/g, 'Bundesverwaltung'],
  [/\bAmministrazione cantonale\b/g, 'Kantonale Verwaltung'],
  [/\bBerna\b/g, 'Bern'],
  // One rendering for an unclear project title that appears in several batches.
  [/Kundschaft: die Verbündete von Bally/g, 'Auftraggeber: «the Bally’s ally»'],
  [/Auftraggeber: «the Bally's ally»/g, 'Auftraggeber: «the Bally’s ally»'],

  // Well-known quotations keep their established German wording (du-form).
  [/«Zweifeln Sie nie daran,/g, '«Zweifle nie daran,'],
]

/** Applies the rules to text outside HTML tags only. */
export function normalize(value) {
  return value
    .split(/(<[^>]+>)/)
    .map((part) => (part.startsWith('<') ? part : RULES.reduce((s, [re, rep]) => s.replace(re, rep), part)))
    .join('')
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const memory = JSON.parse(await readFile(MEMORY, 'utf8'))
  let changed = 0
  for (const [k, v] of Object.entries(memory)) {
    const n = normalize(v)
    if (n !== v) {
      memory[k] = n
      changed++
    }
  }
  await writeFile(MEMORY, JSON.stringify(memory, null, 1) + '\n')
  console.log(`normalised ${changed} segments`)
}
