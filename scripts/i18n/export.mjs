#!/usr/bin/env node
/**
 * Writes every English segment that has no German translation yet into
 * batch files for translation: .cache/i18n/batches/batch-NNN.json
 *
 * Usage: node scripts/i18n/export.mjs [--words 7000]
 */
import { existsSync } from 'node:fs'
import { mkdir, readFile, rm, writeFile } from 'node:fs/promises'
import { join } from 'node:path'
import { MEMORY, pageSegments, segmentKey } from './segments.mjs'

const ROOT = process.cwd()
const OUT = join(ROOT, '.cache/i18n/batches')
const wordsArg = process.argv.indexOf('--words')
const BATCH_WORDS = wordsArg > 0 ? Number(process.argv[wordsArg + 1]) : 7000

const memory = existsSync(MEMORY) ? JSON.parse(await readFile(MEMORY, 'utf8')) : {}
const index = JSON.parse(await readFile(join(ROOT, 'public/content/index.json'), 'utf8'))

// Unique pending segments, ordered by how many pages need them (shared strings first).
const pending = new Map()
for (const entry of index.filter((e) => e.lang === 'en')) {
  const page = JSON.parse(await readFile(join(ROOT, 'public/content/pages', `${entry.id}.json`), 'utf8'))
  for (const text of pageSegments(page)) {
    const key = segmentKey(text)
    if (memory[key] !== undefined) continue
    const seg = pending.get(key) ?? { key, text, uses: 0 }
    seg.uses++
    pending.set(key, seg)
  }
}

const words = (s) => s.replace(/<[^>]+>/g, ' ').split(/\s+/).filter(Boolean).length
const segments = [...pending.values()].sort((a, b) => b.uses - a.uses)

await rm(OUT, { recursive: true, force: true })
await mkdir(OUT, { recursive: true })

let batch = []
let count = 0
let n = 0
let total = 0
const flush = async () => {
  if (!batch.length) return
  n++
  await writeFile(join(OUT, `batch-${String(n).padStart(3, '0')}.json`), JSON.stringify(batch.map(({ key, text }) => ({ key, text })), null, 1))
  batch = []
  count = 0
}
for (const seg of segments) {
  const w = words(seg.text)
  total += w
  if (count + w > BATCH_WORDS && batch.length) await flush()
  batch.push(seg)
  count += w
}
await flush()

console.log(`${segments.length} pending segments, ${total} words, ${n} batches (≈${BATCH_WORDS} words each)`)
