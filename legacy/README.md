# USI — Legacy Edition

The USI website rebuilt from scratch on nine front-end technologies that senior developers stopped reaching for years ago. It has the same real content as the Vue site (English, Italian, Swiss German) and the same design language, but a different decade under the hood.

**Live (password-protected):** https://markchweya.github.io/USI-Lugano/legacy/

| # | Technology | Version | Role |
|---|---|---|---|
| 1 | CoffeeScript | 1.12.7 | All app code, build tasks and specs |
| 2 | Backbone.js | 1.6.0 | Router, models (finder state, preferences), collections, views |
| 3 | jQuery | 3.7.1 | DOM, delegated events, Ajax, number animations |
| 4 | Underscore.js | 1.13.7 | Collection helpers, debouncing, grouping |
| 5 | Handlebars | 4.7.8 | Templates, precompiled at build time (runtime only ships) |
| 6 | RequireJS + r.js | 2.3.7 | AMD modules, bundled into a single file |
| 7 | LESS | 4.2.0 | Design tokens, mixins, the faculty palette loop |
| 8 | Grunt | 1.6.1 | Build, test, dev server, sealing; every task hand-written in `tasks/` |
| 9 | Moment.js | 2.30.1 | Localised dates (it, de) |

## What "better" means here

- **Views clean up after themselves.** Every route is a `Backbone.View` that is removed on navigation, so no listeners leak between pages.
- **State in the URL.** Programme-finder filters live in a Backbone model that syncs to the hash (`#/it/programmi?level=master`), so selections can be shared.
- **One request for the app.** r.js inlines RequireJS and every module into one minified file. Handlebars templates are precompiled with declared helpers, so only the runtime ships.
- **Accessible.** Skip link, route announcements, focus management, a WAI-ARIA tabs pattern, a keyboard search combobox (`/` or ⌘K), WCAG AA colours and reduced-motion support.
- **Tested.** Specs run against the exact AMD modules that ship, loaded through RequireJS in Node: search, routing, i18n key parity and Swiss formatting.

## Password protection

GitHub Pages can't authenticate visitors, so the published app is encrypted:

- `grunt seal` gzips the bundle and encrypts it with **AES-256-GCM**.
- The key is derived from the password with **PBKDF2-SHA256 (600,000 iterations)**.
- The output goes to `sealed/`. The deployed page is only a small gate that decrypts the app in the browser with Web Crypto.
- The password is read from the `LEGACY_PASSWORD` environment variable and is never stored.
- A wrong password fails GCM authentication. Once unlocked, the key is kept for the browser tab's session, and the lock button forgets it.

`sealed/manifest.json` records a SHA-256 digest of the plaintext. CI rebuilds the bundle and fails if `sealed/` is out of date.

This protects the hosted preview. The source code in this repository and the usi.ch content are public either way.

## Commands

```bash
cd legacy
npm install
npx grunt test                              # specs
npx grunt dev                               # build, serve on http://localhost:9001/legacy/, rebuild on change
LEGACY_PASSWORD=… npx grunt seal            # encrypt into ./sealed (commit the result)
npx grunt serve --sealed                    # try the gate locally
npx grunt verify                            # is ./sealed current?
```

## Layout

```
Gruntfile.coffee        task wiring
tasks/                  compile (coffee, templates, styles, bundle), seal, serve, spec
src/coffee/             app, router, i18n (en/it/de), models, collections, views, lib, data
src/templates/          Handlebars templates and partials
src/less/               tokens, mixins, components and page styles
src/gate/               the password gate (plain ES5 + Web Crypto)
spec/                   specs
sealed/                 the encrypted, publishable build
```

Content is fetched at runtime from the main site's `/content/` folder. It is the real usi.ch pages, mirrored by `scripts/usi` in the repository root.
