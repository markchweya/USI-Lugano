# USI Lugano — a better website

A ground-up redesign of the [Università della Svizzera italiana](https://www.usi.ch) website, built with **Vue 3 + TypeScript + Vite**, driven by **real content** mirrored from usi.ch, in **English, Italian and Swiss German**.

**Live:** https://markchweya.github.io/USI-Lugano/ (`/en`, `/it`, `/de`)

## Highlights

- **Real content, three languages.** Thousands of public usi.ch pages are crawled, sanitised and re-rendered in the new design, at their original URLs. Italian uses USI's own Italian pages; German (which usi.ch doesn't publish) is translated through a validated pipeline and labelled as a translation, with a link to the original.
- **Localised everything.** UI dictionaries are fully typed (a missing translation is a compile error), URLs use local slugs (`/it/programmi`, `/de/studiengaenge`), numbers and dates follow Swiss conventions (4’749), and the language switcher keeps you on the same page.
- **⌘K / `/` search** over the current language's pages, accent-insensitive and keyboard-driven.
- **Programme finder** with filters stored in the URL, an **Explore** directory of every page, and content pages with breadcrumbs, a programme sub-menu, a table of contents and related pages.
- **Editorial design system:** paper and ink neutrals, a lake blue and one signal colour, Fraunces + Inter Tight (self-hosted), light/dark/system themes, generative faculty art and USI's own campus photography.
- **Accessible and fast:** zero axe violations on audited pages (both themes), WCAG AA contrast, skip link, route announcer and focus management. Each language loads only its own content index; routes are code-split; videos load only on click.
- **SEO:** every page is pre-rendered as static HTML with its own title, description, canonical URL, `<html lang>` and hreflang alternates.

## Getting started

```bash
npm install
npm run dev        # http://localhost:5173
npm run build      # type-check + production build
npm test           # unit tests (vitest)
```

## Deployment

Every push to `main` or `ChweyasBranch` runs `.github/workflows/deploy-pages.yml`: install → test → build with `BASE_PATH=/USI-Lugano/` → `scripts/static-routes.mjs` → publish `dist/` to the `gh-pages` branch.

## Content pipeline

```
usi.ch ──crawl.mjs──▶ .cache/usi/*.html ──extract.mjs──▶ public/content/
                                                          ├─ pages/<id>.json     one file per page (en, it, de)
                                                          ├─ index.<lang>.json   per-language index the browser loads
                                                          └─ index.json          full index for build scripts
                                          i18n/de/memory.json ─┘ (German pages are built from the translation memory)
```

```bash
NODE_USE_ENV_PROXY=1 node scripts/usi/crawl.mjs --max 6000   # polite: honours robots.txt and its 10 s crawl delay
node scripts/usi/extract.mjs                                  # offline, fast, re-runnable
node scripts/usi/commit-content.mjs <en|it|de>                # commit new content one section at a time
```

- **Crawler:** respects `robots.txt` (disallow rules and crawl delay), identifies itself, saves its state after every page so it can resume, fetches the Italian twin of each English page first, and **never bypasses bot protection**. Challenge-protected pages are skipped and their links open on usi.ch.
- **Extractor:** converts USI's Drupal markup into typed blocks (rich text, galleries, accordions, testimonials, card grids, videos). It sanitises HTML to a strict tag/attribute allow-list and repairs usi.ch quirks (truncated descriptions, URL-encoded headings, slug breadcrumbs). Images are referenced from usi.ch, not copied.

## German translation

```bash
node scripts/i18n/export.mjs        # batch every untranslated English segment → .cache/i18n/batches/
# translate each batch into .cache/i18n/out/batch-NNN.json following i18n/de/STYLEGUIDE.md
node scripts/i18n/check.mjs <batch> <out>   # same HTML skeleton and links, no ß, plausible length
node scripts/i18n/import.mjs        # validate, normalise terminology, merge into i18n/de/memory.json
node scripts/usi/extract.mjs        # rebuild: a page goes German once every segment is translated
```

- **Translation memory** (`i18n/de/memory.json`) is keyed by a hash of each English segment, so shared strings are translated once and edited English text is re-translated automatically.
- **Style guide** (`i18n/de/STYLEGUIDE.md`) defines Swiss Standard German (ss, formal Sie, gender-inclusive forms, «» quotes) and the terminology table.
- **Normalisation** (`scripts/i18n/normalize.mjs`, unit-tested) enforces one name per office, body and place, with correct German grammatical case, and only ever touches text between HTML tags.

## Project structure

```
src/
  i18n/           typed dictionaries (en, it, de), locale routing helpers
  content/        content types, lazy per-language content API, data-driven navigation
  components/     header (mega-menu, language switcher), command palette, footer, cards
    content/      block renderer, rich text, carousel, YouTube facade
    home/         hero photo
    ui/           icons, generative faculty art, primitives
  views/          Home, Study (finder), Explore, ContentPage (any real page), 404
  lib/            search engine (+ tests), search index
  styles/         design tokens and base styles
scripts/usi/      crawler, extractor, per-section content commits
scripts/i18n/     German translation pipeline
scripts/          static-route generation for GitHub Pages
i18n/de/          German translation memory and style guide
```

## Note

This is an independent redesign concept. All content belongs to USI and is shown with a link to its source; check usi.ch for authoritative information.
