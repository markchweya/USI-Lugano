#!/usr/bin/env node
/**
 * Post-build step for static hosting (GitHub Pages).
 *
 * Writes dist/<route>/index.html for every app route and every mirrored
 * page, each with its own <title>, description and canonical link. Deep
 * links then return HTTP 200 with meaningful metadata instead of falling
 * through to 404.html. 404.html remains as the fallback for anything else.
 */
import { mkdir, readFile, writeFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'

const DIST = join(process.cwd(), 'dist')
const SUFFIX = 'USI — Università della Svizzera italiana'
const SITE = process.env.SITE_URL?.replace(/\/$/, '') ?? ''

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')

const template = await readFile(join(DIST, 'index.html'), 'utf8')
const index = JSON.parse(await readFile(join(DIST, 'content/index.json'), 'utf8'))

const routes = [
  { path: '/study', title: 'Find a programme', description: 'Every Bachelor and Master programme at USI, filterable by level, faculty and language.' },
  { path: '/explore', title: 'Explore', description: 'Every public page of USI, organised and searchable.' },
  ...index.map((e) => ({ path: e.path, title: e.title, description: e.description })),
]

function render({ path, title, description }) {
  let html = template.replace(/<title>[^<]*<\/title>/, `<title>${esc(`${title} · ${SUFFIX}`)}</title>`)
  if (description) html = html.replace(/(<meta name="description" content=")[^"]*(")/, `$1${esc(description)}$2`)
  if (SITE) html = html.replace('</head>', `    <link rel="canonical" href="${esc(SITE + encodeURI(path))}" />\n  </head>`)
  return html
}

await Promise.all([
  writeFile(join(DIST, '404.html'), template),
  ...routes.map(async (r) => {
    const file = join(DIST, decodeURI(r.path), 'index.html')
    await mkdir(dirname(file), { recursive: true })
    await writeFile(file, render(r))
  }),
])
await writeFile(join(DIST, '.nojekyll'), '')
console.log(`static routes: ${routes.length} pages + 404 fallback`)
