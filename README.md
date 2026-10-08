# USI Lugano — a better website

A ground-up redesign of the [Università della Svizzera italiana](https://www.usi.ch) website, built with **Vue 3 + TypeScript + Vite**, driven by **real content** mirrored from usi.ch (1,000+ pages).

## Highlights

- **Real content, not lorem ipsum** — every public page is crawled, sanitised and re-rendered in the new design. Original URLs are preserved (`/en/education/bachelor/informatics` works here exactly as on usi.ch).
- **⌘K / `/` command palette** — accent-insensitive, ranked search across every page and programme, fully keyboard-driven (ARIA combobox).
- **Programme finder** — filter by level, faculty and teaching language; the state lives in the URL, so results are shareable.
- **Explore** — the whole site as a navigable, filterable directory.
- **Data-driven navigation** — mega-menus and footer are generated from the real site hierarchy, so they never drift from the content.
- **Editorial design system** — paper & ink neutrals, a lake blue and one signal colour; Fraunces + Inter Tight (self-hosted); fluid type; light/dark/system themes with no flash.
- **Generative faculty art** — each faculty has a deterministic SVG signature instead of stock imagery.
- **Accessible & fast** — skip link, route announcer, focus management, `prefers-reduced-motion`, semantic landmarks; route-level code splitting; content fetched lazily so the corpus never bloats the JS bundle; YouTube embeds load only on click (privacy-enhanced domain).

## Getting started

```bash
npm install
npm run dev        # http://localhost:5173
npm run build      # type-check + production build
npm test           # unit tests (vitest)
```

## Content pipeline

```
usi.ch ──crawl.mjs──▶ .cache/usi/*.html ──extract.mjs──▶ public/content/  (index + one JSON per page)
                                                       └▶ src/data/generated/ (programmes, events, stats)
```

```bash
NODE_USE_ENV_PROXY=1 node scripts/usi/crawl.mjs --max 1400   # slow on purpose: honours robots.txt Crawl-delay (10 s)
node scripts/usi/extract.mjs                                  # offline, fast, re-runnable
```

- The crawler respects `robots.txt` (disallow rules and crawl delay), identifies itself, is resumable, and **never bypasses bot protection** — pages behind a challenge (e.g. individual news items, `search.usi.ch`) are recorded and skipped. Those links open on usi.ch instead.
- The extractor converts USI's Drupal markup into typed blocks (rich text, galleries, accordions, testimonials, card grids, videos) and sanitises HTML to a strict tag/attribute allow-list; only `http(s)`, `mailto:` and `tel:` links survive.
- Images are referenced from usi.ch, not copied.

## Project structure

```
src/
  content/        types, lazy content API, data-driven navigation
  components/     header (mega-menu), command palette, footer, cards
    content/      block renderer, rich text, carousel, YouTube facade
    home/         hero illustration
    ui/           icons, generative faculty art, primitives
  views/          Home, Study (finder), Explore, ContentPage (any real page), 404
  lib/            search engine (+ tests), search index
  styles/         design tokens and base styles
scripts/usi/      crawler and extractor
```

## Note

This is an independent redesign concept. All content belongs to USI and is shown with a link to its source; check usi.ch for authoritative information.
