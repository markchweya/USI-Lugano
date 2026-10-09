#!/usr/bin/env node
/**
 * Validates a translated batch against its source batch.
 * Usage: node scripts/i18n/check.mjs .cache/i18n/batches/batch-001.json .cache/i18n/out/batch-001.json
 * Exit code 1 and a list of problems if anything is wrong.
 */
import { readFile } from 'node:fs/promises'
import { checkTranslation } from './segments.mjs'

const [srcFile, outFile] = process.argv.slice(2)
const source = JSON.parse(await readFile(srcFile, 'utf8'))
let out
try {
  out = JSON.parse(await readFile(outFile, 'utf8'))
} catch (err) {
  console.error(`invalid JSON in ${outFile}: ${err.message}`)
  process.exit(1)
}

const problems = []
for (const { key, text } of source) {
  if (!(key in out)) problems.push(`${key}: missing`)
  else {
    const err = checkTranslation(text, out[key])
    if (err) problems.push(`${key}: ${err}`)
  }
}
const extra = Object.keys(out).filter((k) => !source.some((s) => s.key === k))
extra.forEach((k) => problems.push(`${k}: not in source`))

if (problems.length) {
  console.error(`${problems.length} problem(s):\n${problems.join('\n')}`)
  process.exit(1)
}
console.log(`OK — ${source.length} segments`)
