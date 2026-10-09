#!/usr/bin/env node
/**
 * Commits newly extracted content in reviewable units: one commit per
 * language + top-level section (e.g. "Italian content: Formazione").
 * Usage: node scripts/usi/commit-content.mjs <lang> [--dry]
 */
import { execFileSync } from 'node:child_process'
import { readFileSync } from 'node:fs'

const [lang, flag] = process.argv.slice(2)
const dry = flag === '--dry'
const names = { en: 'English', it: 'Italian', de: 'German' }

const git = (...args) => execFileSync('git', args, { encoding: 'utf8' })
const changed = new Set(
  git('status', '--porcelain', '--', 'public/content/pages')
    .split('\n')
    .filter(Boolean)
    .map((l) => l.slice(3).trim()),
)
const index = JSON.parse(readFileSync('public/content/index.json', 'utf8'))

const groups = new Map()
for (const e of index) {
  if (e.lang !== lang) continue
  const file = `public/content/pages/${e.id}.json`
  if (!changed.has(file)) continue
  const key = e.path.split('/')[2] ?? 'home'
  if (!groups.has(key)) groups.set(key, { label: e.crumbs[0] ?? e.section ?? key, files: [], titles: [] })
  const g = groups.get(key)
  g.files.push(file)
  g.titles.push(e.title)
}

for (const [key, g] of groups) {
  const body = g.titles.slice(0, 12).map((t) => `- ${t}`).join('\n') + (g.titles.length > 12 ? `\n- …and ${g.titles.length - 12} more` : '')
  const msg = `${names[lang]} content: ${g.label} (${g.files.length} ${g.files.length === 1 ? 'page' : 'pages'})\n\n${body}`
  console.log(`${key}: ${g.files.length} files`)
  if (!dry) {
    git('add', '--', ...g.files)
    git('commit', '-q', '-m', msg)
  }
}
