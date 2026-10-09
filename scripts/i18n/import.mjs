#!/usr/bin/env node
/**
 * Merges validated translated batches into the translation memory
 * (i18n/de/memory.json). Invalid segments are skipped and reported.
 */
import { existsSync } from 'node:fs'
import { mkdir, readdir, readFile, writeFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { MEMORY, checkTranslation } from './segments.mjs'
import { normalize } from './normalize.mjs'

const SRC = '.cache/i18n/batches'
const OUT = '.cache/i18n/out'
const memory = existsSync(MEMORY) ? JSON.parse(await readFile(MEMORY, 'utf8')) : {}

let added = 0
let rejected = 0
for (const f of (await readdir(OUT)).filter((f) => f.endsWith('.json')).sort()) {
  if (!existsSync(join(SRC, f))) continue
  const source = JSON.parse(await readFile(join(SRC, f), 'utf8'))
  let out
  try {
    out = JSON.parse(await readFile(join(OUT, f), 'utf8'))
  } catch {
    console.warn(`${f}: invalid JSON, skipped`)
    continue
  }
  for (const { key, text } of source) {
    if (!(key in out)) continue
    if (checkTranslation(text, out[key])) {
      rejected++
      continue
    }
    if (memory[key] === undefined) added++
    memory[key] = normalize(out[key])
  }
}

// Re-apply terminology rules to everything, so rule changes reach older entries too.
for (const k of Object.keys(memory)) memory[k] = normalize(memory[k])

// Stable key order keeps diffs of the committed memory readable.
const sorted = Object.fromEntries(Object.entries(memory).sort(([a], [b]) => a.localeCompare(b)))
await mkdir(dirname(MEMORY), { recursive: true })
await writeFile(MEMORY, JSON.stringify(sorted, null, 1) + '\n')
console.log(`memory: ${Object.keys(sorted).length} segments (+${added}, ${rejected} rejected)`)
