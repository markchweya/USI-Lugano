<script setup lang="ts">
import { computed, onBeforeUnmount, ref, shallowRef, watch } from 'vue'
import { useRoute } from 'vue-router'
import { findEntry, langOfPath, loadIndex, loadPage, normalizePath } from '@/content/api'
import type { Page, PageEntry } from '@/content/types'
import { findProgramme, useDuration } from '@/data/programmes'
import { useFaculties } from '@/data/faculties'
import { usePageTitle } from '@/composables/usePageTitle'
import { useCommandPalette } from '@/composables/useCommandPalette'
import { setAlternates } from '@/composables/useAlternates'
import { useI18n, type Locale } from '@/i18n'
import { slugify } from '@/lib/slugify'
import BlockRenderer from '@/components/content/BlockRenderer.vue'
import SmartLink from '@/components/ui/SmartLink.vue'
import UiIcon from '@/components/ui/UiIcon.vue'
import PageCard from '@/components/PageCard.vue'

const route = useRoute()
const palette = useCommandPalette()
const { m, d } = useI18n()
const faculties = useFaculties()
const duration = useDuration()

const page = shallowRef<Page | null>(null)
const index = shallowRef<PageEntry[]>([])
const state = ref<'loading' | 'ready' | 'missing' | 'error'>('loading')
/** German page not translated yet: we show the English original with a notice. */
const fallback = ref(false)

const path = computed(() => normalizePath(route.path))
const toDe = (enPath: string) => `/de${enPath.slice(3)}`

watch(
  path,
  async (p) => {
    state.value = 'loading'
    page.value = null
    fallback.value = false
    try {
      const [entry, all] = await Promise.all([findEntry(p), loadIndex(langOfPath(p))])
      index.value = all
      const target = entry
      // German index lists not-yet-translated English pages; show the original with a notice.
      fallback.value = !!entry?.untranslated
      if (!target) {
        state.value = 'missing'
        setAlternates({})
        return
      }
      page.value = await loadPage(target.id)
      state.value = 'ready'
      setAlternates(alternatesOf(page.value, p))
    } catch {
      state.value = 'error'
    }
  },
  { immediate: true },
)

onBeforeUnmount(() => setAlternates({}))

/** Where this page lives in each language. German mirrors the English path. */
function alternatesOf(pg: Page, current: string): Partial<Record<Locale, string>> {
  const en = pg.lang === 'en' ? pg.path : pg.alternates.en
  return {
    en,
    it: pg.alternates.it ?? (pg.lang === 'it' ? pg.path : undefined),
    de: current.startsWith('/de/') ? current : en ? toDe(en) : undefined,
  }
}

usePageTitle(() => (state.value === 'ready' ? page.value?.title : state.value === 'missing' ? m.value.notFound.title : undefined))

const programme = computed(() => findProgramme(path.value) ?? (page.value ? findProgramme(page.value.path) : undefined))
const faculty = computed(() => faculties.get(programme.value?.faculty))
const isTranslation = computed(() => !!page.value?.translated)
const originalPath = computed(() => (path.value.startsWith('/de/') ? `/en${path.value.slice(3)}` : null))

const toc = computed(() => (page.value?.blocks ?? []).filter((b) => b.t === 'h' && b.level === 2).map((b) => (b.t === 'h' ? b.text : '')))

/** Lead media: a gallery or video that opens the page is promoted to a full-width hero. */
const heroBlocks = computed(() => {
  const first = page.value?.blocks[0]
  return first && (first.t === 'gallery' || first.t === 'video') ? [first] : []
})
const bodyBlocks = computed(() => page.value?.blocks.slice(heroBlocks.value.length) ?? [])

const depth = (p: string) => p.split('/').length
/** Children/siblings are looked up in the language actually shown. */
const basePath = computed(() => (fallback.value && page.value ? page.value.path : path.value))
const childPages = computed(() =>
  index.value
    .filter((e) => e.path.startsWith(`${basePath.value}/`) && depth(e.path) === depth(basePath.value) + 1)
    .sort((a, b) => a.title.localeCompare(b.title)),
)
const siblingPages = computed(() => {
  const parent = basePath.value.split('/').slice(0, -1).join('/')
  if (depth(parent) < 3) return []
  return index.value.filter((e) => e.path !== basePath.value && e.path.startsWith(`${parent}/`) && depth(e.path) === depth(basePath.value)).slice(0, 6)
})

const facts = computed(() => {
  const p = programme.value
  if (!p) return []
  const lang = (l: 'EN' | 'IT') => (l === 'EN' ? m.value.programme.english : m.value.programme.italian)
  return [
    { k: m.value.programme.level, v: m.value.levels[p.level] },
    { k: m.value.programme.faculty, v: faculty.value?.short },
    { k: m.value.programme.credits, v: p.ects ? `${p.ects} ECTS` : null },
    { k: m.value.programme.duration, v: duration(p) },
    { k: m.value.programme.language, v: p.languages.length ? p.languages.map(lang).join(` ${m.value.programme.and} `) : null },
  ].filter((f) => f.v)
})

const updated = computed(() => (page.value ? d(page.value.fetchedAt, { day: 'numeric', month: 'short', year: 'numeric' }) : ''))
</script>

<template>
  <div class="page" :style="faculty ? { '--accent': faculty.color } : undefined">
    <!-- Loading skeleton -->
    <div v-if="state === 'loading'" class="container skeleton" aria-busy="true" :aria-label="m.page.loading">
      <div class="sk sk-crumb" />
      <div class="sk sk-title" />
      <div class="sk sk-line" />
      <div class="sk sk-line short" />
      <div class="sk sk-media" />
    </div>

    <!-- Not in our corpus -->
    <div v-else-if="state === 'missing' || state === 'error'" class="container missing">
      <p class="eyebrow">{{ state === 'error' ? m.page.connection : m.page.notMirrored }}</p>
      <h1>{{ state === 'error' ? m.page.errorTitle : m.page.missingTitle }}</h1>
      <p class="lede">{{ m.page.missingLede }}</p>
      <div class="missing-actions">
        <a :href="`https://www.usi.ch${originalPath ?? path}`" class="btn" target="_blank" rel="noopener">{{ m.page.openOriginal }} <UiIcon name="arrow-up-right" :size="16" /></a>
        <button type="button" class="btn btn--ghost" @click="palette.open()"><UiIcon name="search" :size="16" /> {{ m.page.searchInstead }}</button>
      </div>
    </div>

    <article v-else-if="page">
      <header class="hero container">
        <nav class="crumbs" :aria-label="m.page.breadcrumb">
          <ol role="list">
            <li v-for="(c, i) in page.breadcrumb" :key="i">
              <SmartLink v-if="c.path && i < page.breadcrumb.length - 1" :href="c.path">{{ c.label }}</SmartLink>
              <span v-else aria-current="page">{{ c.label }}</span>
            </li>
          </ol>
        </nav>

        <div class="hero-grid">
          <div>
            <p v-if="programme" class="eyebrow accent">{{ m.programme.kind(m.levels[programme.level]) }}</p>
            <p v-else class="eyebrow">{{ page.section }}</p>
            <h1 class="title">{{ page.title }}</h1>
            <p v-if="page.description" class="lede">{{ page.description }}</p>
          </div>
          <div class="hero-meta">
            <SmartLink v-for="c in page.ctas" :key="c.href" :href="c.href" class="btn" :class="{ 'btn--signal': c === page.ctas[0], 'btn--ghost': c !== page.ctas[0] }">
              {{ c.label }} <UiIcon name="arrow-right" :size="16" />
            </SmartLink>
            <div class="meta-row">
              <span v-if="isTranslation" class="chip chip--solid"><UiIcon name="language" :size="14" /> {{ m.programme.translated }}</span>
              <a :href="page.source" class="chip" target="_blank" rel="noopener">{{ m.page.original }} <UiIcon name="arrow-up-right" :size="12" /></a>
            </div>
          </div>
        </div>

        <aside v-if="isTranslation || fallback" class="notice" role="note">
          <UiIcon name="language" :size="18" />
          <p>
            {{ fallback ? m.page.notTranslated : m.page.translatedNotice }}
            <RouterLink v-if="isTranslation && originalPath" :to="originalPath" lang="en">{{ m.page.translatedFrom }}</RouterLink>
          </p>
        </aside>

        <dl v-if="facts.length" class="facts">
          <div v-for="f in facts" :key="f.k">
            <dt>{{ f.k }}</dt>
            <dd>{{ f.v }}</dd>
          </div>
        </dl>
      </header>

      <div v-if="heroBlocks.length" class="container hero-media">
        <BlockRenderer :blocks="heroBlocks" />
      </div>

      <div class="container body">
        <div class="main-col">
          <BlockRenderer v-if="bodyBlocks.length" :blocks="bodyBlocks" />
          <p v-else-if="!childPages.length" class="lede">{{ m.page.directory }}</p>

          <section v-if="childPages.length" class="children" aria-labelledby="in-section">
            <h2 id="in-section" class="sub-title">{{ m.page.inSection }}</h2>
            <div class="grid">
              <PageCard v-for="c in childPages" :key="c.id" :entry="c" />
            </div>
          </section>
        </div>

        <aside class="side">
          <div class="sticky">
            <nav v-if="toc.length > 1" class="side-block" :aria-label="m.page.onThisPage">
              <p class="side-title">{{ m.page.onThisPage }}</p>
              <ul role="list">
                <li v-for="t in toc" :key="t"><a :href="`#${slugify(t)}`">{{ t }}</a></li>
              </ul>
            </nav>
            <nav v-if="page.nav.length" class="side-block" :aria-label="m.page.inProgramme">
              <p class="side-title">{{ m.page.inProgramme }}</p>
              <ul role="list">
                <li v-for="n in page.nav" :key="n.href">
                  <SmartLink :href="n.href" :class="{ current: n.href === page.path || n.href === path }">{{ n.label }}</SmartLink>
                </li>
              </ul>
            </nav>
            <nav v-if="page.links.length" class="side-block" :aria-label="m.page.quickLinks">
              <p class="side-title">{{ m.page.quickLinks }}</p>
              <ul role="list">
                <li v-for="l in page.links" :key="l.href">
                  <SmartLink :href="l.href">{{ l.label }} <UiIcon name="arrow-up-right" :size="12" /></SmartLink>
                </li>
              </ul>
            </nav>
            <p class="synced">{{ m.page.synced(updated) }}</p>
          </div>
        </aside>
      </div>

      <section v-if="siblingPages.length" class="container related" aria-labelledby="related">
        <h2 id="related" class="sub-title">{{ m.page.related }}</h2>
        <div class="grid">
          <PageCard v-for="s in siblingPages" :key="s.id" :entry="s" />
        </div>
      </section>
    </article>
  </div>
</template>

<style scoped>
.page {
  --accent: var(--signal);
  padding-top: clamp(1.5rem, 4vw, 3rem);
}

/* Hero */
.crumbs ol {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  font-size: 0.85rem;
  color: var(--ink-3);
}
.crumbs li:not(:last-child)::after {
  content: '/';
  margin-left: 0.35rem;
  opacity: 0.5;
}
.crumbs a {
  text-decoration: none;
}
.crumbs a:hover {
  color: var(--ink);
}
.hero-grid {
  display: grid;
  gap: 2rem;
  margin-top: clamp(1.5rem, 4vw, 3rem);
  align-items: end;
}
@media (min-width: 1000px) {
  .hero-grid {
    grid-template-columns: 1fr 300px;
  }
}
.eyebrow.accent {
  color: var(--accent);
}
.title {
  margin-top: 1rem;
  font-size: var(--step-5);
  max-width: 18ch;
}
.lede {
  max-width: 62ch;
  margin-top: 1.5rem;
  font-size: var(--step-1);
  line-height: 1.55;
  color: var(--ink-2);
}
.hero-meta {
  display: grid;
  gap: 0.6rem;
  justify-items: start;
}
@media (min-width: 1000px) {
  .hero-meta {
    justify-items: stretch;
  }
}
.meta-row {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-top: 0.4rem;
}
.meta-row .chip {
  text-decoration: none;
}
.meta-row a.chip:hover {
  border-color: var(--ink);
  color: var(--ink);
}
.facts {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1px;
  margin: clamp(2rem, 4vw, 3rem) 0 0;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: var(--line);
}
.facts div {
  padding: 1rem 1.25rem;
  background: var(--surface);
}
.facts dt {
  font-family: var(--font-mono);
  font-size: 0.7rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--ink-3);
}
.facts dd {
  margin: 0.3rem 0 0;
  font-family: var(--font-display);
  font-size: var(--step-1);
}
.notice {
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
  margin-top: 2rem;
  padding: 1rem 1.25rem;
  border: 1px solid var(--line);
  border-left: 3px solid var(--lake);
  border-radius: var(--radius-sm);
  background: var(--lake-soft);
  color: var(--ink-2);
  font-size: 0.92rem;
}
.notice .icon {
  margin-top: 0.15rem;
  color: var(--lake);
}
.notice a {
  margin-left: 0.25rem;
  color: var(--ink);
  font-weight: 600;
}
.hero-media {
  margin-top: clamp(2rem, 4vw, 3rem);
}

/* Body */
.body {
  display: grid;
  gap: 3rem;
  margin-top: clamp(2.5rem, 5vw, 4rem);
}
@media (min-width: 1000px) {
  .body {
    grid-template-columns: minmax(0, 1fr) 280px;
    gap: 5rem;
  }
}
.main-col {
  min-width: 0;
}
.sticky {
  position: sticky;
  top: calc(var(--header-h) + 1.5rem);
  display: grid;
  gap: 1.25rem;
}
.side-block {
  padding: 1.25rem;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: var(--surface);
}
.side-title {
  margin-bottom: 0.75rem;
  font-family: var(--font-mono);
  font-size: 0.7rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--ink-3);
}
.side-block ul {
  display: grid;
  gap: 0.15rem;
}
.side-block a {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.35rem 0.5rem;
  margin-inline: -0.5rem;
  border-radius: 8px;
  color: var(--ink-2);
  font-size: 0.9rem;
  text-decoration: none;
  transition: background-color var(--dur);
}
.side-block a:hover {
  background: var(--paper-2);
  color: var(--ink);
}
.side-block a.current {
  color: var(--ink);
  font-weight: 600;
  box-shadow: inset 2px 0 0 var(--accent);
}
.synced {
  font-size: 0.75rem;
  color: var(--ink-3);
}

.sub-title {
  margin-bottom: 1.5rem;
  font-size: var(--step-3);
}
.children {
  margin-top: 4rem;
}
.related {
  margin-top: var(--section);
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 260px), 1fr));
  gap: 1rem;
}

/* States */
.missing {
  display: grid;
  gap: 1rem;
  justify-items: start;
  padding-block: var(--section);
}
.missing h1 {
  font-size: var(--step-4);
  max-width: 20ch;
}
.missing-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-top: 1rem;
}
.skeleton {
  display: grid;
  gap: 1rem;
}
.sk {
  border-radius: 10px;
  background: linear-gradient(90deg, var(--paper-2) 0%, var(--surface) 50%, var(--paper-2) 100%);
  background-size: 200% 100%;
  animation: shine 1.4s linear infinite;
}
.sk-crumb {
  width: 220px;
  height: 14px;
}
.sk-title {
  width: min(640px, 90%);
  height: 72px;
  margin-top: 2rem;
}
.sk-line {
  width: min(560px, 80%);
  height: 18px;
}
.sk-line.short {
  width: 40%;
}
.sk-media {
  height: 360px;
  margin-top: 2rem;
  border-radius: var(--radius);
}
@keyframes shine {
  to {
    background-position: -200% 0;
  }
}
</style>
