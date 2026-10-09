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
const known = new Set(index.map((e) => e.path))

// App pages per language, with localised slugs and titles (kept in sync with src/i18n).
const app = {
  en: { lang: 'en', home: 'Home', study: ['study', 'Find a programme'], explore: ['explore', 'Explore'], desc: 'Università della Svizzera italiana — a young, international university in Lugano, Switzerland.' },
  it: { lang: 'it', home: 'Home', study: ['programmi', 'Trova un corso di studio'], explore: ['esplora', 'Esplora'], desc: 'Università della Svizzera italiana — un’università giovane e internazionale a Lugano, in Svizzera.' },
  de: { lang: 'de', home: 'Startseite', study: ['studiengaenge', 'Studiengang finden'], explore: ['entdecken', 'Entdecken'], desc: 'Università della Svizzera italiana — eine junge, internationale Universität in Lugano, Schweiz.' },
}

const appAlternates = (page) =>
  Object.fromEntries(Object.entries(app).map(([l, a]) => [l, page === 'home' ? `/${l}` : `/${l}/${a[page][0]}`]))

const routes = [
  ...Object.entries(app).flatMap(([l, a]) => [
    { path: `/${l}`, title: null, description: a.desc, lang: a.lang, alternates: appAlternates('home') },
    { path: `/${l}/${a.study[0]}`, title: a.study[1], description: a.desc, lang: a.lang, alternates: appAlternates('study') },
    { path: `/${l}/${a.explore[0]}`, title: a.explore[1], description: a.desc, lang: a.lang, alternates: appAlternates('explore') },
  ]),
  ...(await Promise.all(
    index.map(async (e) => {
      const page = JSON.parse(await readFile(join(DIST, 'content/pages', `${e.id}.json`), 'utf8'))
      // Only advertise alternates that actually exist as pages.
      const alternates = Object.fromEntries(Object.entries(page.alternates ?? {}).filter(([, p]) => known.has(p)))
      return { path: e.path, title: e.title, description: e.description, lang: e.lang, alternates }
    }),
  )),
]

function render({ path, title, description, lang, alternates }) {
  let html = template.replace(/<title>[^<]*<\/title>/, `<title>${esc(title ? `${title} · ${SUFFIX}` : SUFFIX)}</title>`)
  html = html.replace('<html lang="en">', `<html lang="${lang}">`)
  if (description) html = html.replace(/(<meta name="description" content=")[^"]*(")/, `$1${esc(description)}$2`)
  if (SITE) {
    const links = [`<link rel="canonical" href="${esc(SITE + encodeURI(path))}" />`]
    const alts = Object.entries(alternates ?? {})
    if (alts.length > 1) {
      for (const [l, p] of alts) links.push(`<link rel="alternate" hreflang="${l}" href="${esc(SITE + encodeURI(p))}" />`)
      const fallback = alternates.en ?? alts[0][1]
      links.push(`<link rel="alternate" hreflang="x-default" href="${esc(SITE + encodeURI(fallback))}" />`)
    }
    html = html.replace('</head>', `    ${links.join('\n    ')}\n  </head>`)
  }
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
