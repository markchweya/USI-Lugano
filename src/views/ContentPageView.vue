<script setup lang="ts">
import { computed, ref, shallowRef, watch } from 'vue'
import { useRoute } from 'vue-router'
import { findEntry, loadIndex, loadPage, normalizePath } from '@/content/api'
import type { Page, PageEntry } from '@/content/types'
import { programmes, levelLabels, formatDuration } from '@/data/programmes'
import { getFaculty } from '@/data/faculties'
import { usePageTitle } from '@/composables/usePageTitle'
import { useCommandPalette } from '@/composables/useCommandPalette'
import { slugify } from '@/lib/slugify'
import BlockRenderer from '@/components/content/BlockRenderer.vue'
import SmartLink from '@/components/ui/SmartLink.vue'
import UiIcon from '@/components/ui/UiIcon.vue'
import PageCard from '@/components/PageCard.vue'

const route = useRoute()
const palette = useCommandPalette()

const page = shallowRef<Page | null>(null)
const index = shallowRef<PageEntry[]>([])
const state = ref<'loading' | 'ready' | 'missing' | 'error'>('loading')

const path = computed(() => normalizePath(route.path))

watch(
  path,
  async (p) => {
    state.value = 'loading'
    page.value = null
    try {
      const [entry, all] = await Promise.all([findEntry(p), loadIndex()])
      index.value = all
      if (!entry) {
        state.value = 'missing'
        return
      }
      page.value = await loadPage(entry.id)
      state.value = 'ready'
    } catch {
      state.value = 'error'
    }
  },
  { immediate: true },
)

usePageTitle(() => (state.value === 'ready' ? page.value?.title : state.value === 'missing' ? 'Page not found' : undefined))

const programme = computed(() => programmes.find((p) => p.path === path.value))
const faculty = computed(() => getFaculty(programme.value?.faculty))

const toc = computed(() => (page.value?.blocks ?? []).filter((b) => b.t === 'h' && b.level === 2).map((b) => (b.t === 'h' ? b.text : '')))

/** Lead media: a gallery or video that opens the page is promoted to a full-width hero. */
const heroBlocks = computed(() => {
  const first = page.value?.blocks[0]
  return first && (first.t === 'gallery' || first.t === 'video') ? [first] : []
})
const bodyBlocks = computed(() => page.value?.blocks.slice(heroBlocks.value.length) ?? [])

const depth = (p: string) => p.split('/').length
const childPages = computed(() =>
  index.value.filter((e) => e.path.startsWith(`${path.value}/`) && depth(e.path) === depth(path.value) + 1).sort((a, b) => a.title.localeCompare(b.title)),
)
const siblingPages = computed(() => {
  const parent = path.value.split('/').slice(0, -1).join('/')
  if (depth(parent) < 3) return []
  return index.value.filter((e) => e.path !== path.value && e.path.startsWith(`${parent}/`) && depth(e.path) === depth(path.value)).slice(0, 6)
})

const facts = computed(() => {
  const p = programme.value
  if (!p) return []
  return [
    { k: 'Level', v: levelLabels[p.level] },
    { k: 'Faculty', v: faculty.value?.short },
    { k: 'Credits', v: p.ects ? `${p.ects} ECTS` : null },
    { k: 'Duration', v: formatDuration(p) },
    { k: 'Language', v: p.languages.length ? p.languages.map((l) => (l === 'EN' ? 'English' : 'Italian')).join(' & ') : null },
  ].filter((f) => f.v)
})

const otherLang = computed(() => {
  const p = page.value
  if (!p) return null
  const target = p.lang === 'en' ? 'it' : 'en'
  const href = p.alternates[target]
  return href && href !== p.path ? { href, label: target === 'en' ? 'English' : 'Italiano' } : null
})

const updated = computed(() => (page.value ? new Date(page.value.fetchedAt).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }) : ''))
</script>

<template>
  <div class="page" :style="faculty ? { '--accent': faculty.color } : undefined">
    <!-- Loading skeleton -->
    <div v-if="state === 'loading'" class="container skeleton" aria-busy="true" aria-label="Loading page">
      <div class="sk sk-crumb" />
      <div class="sk sk-title" />
      <div class="sk sk-line" />
      <div class="sk sk-line short" />
      <div class="sk sk-media" />
    </div>

    <!-- Not in our corpus -->
    <div v-else-if="state === 'missing' || state === 'error'" class="container missing">
      <p class="eyebrow">{{ state === 'error' ? 'Connection problem' : 'Not mirrored yet' }}</p>
      <h1>{{ state === 'error' ? 'We couldn’t load this page.' : 'This page isn’t part of the redesign yet.' }}</h1>
      <p class="lede">It may still exist on the current USI website.</p>
      <div class="missing-actions">
        <a :href="`https://www.usi.ch${path}`" class="btn" target="_blank" rel="noopener">Open on usi.ch <UiIcon name="arrow-up-right" :size="16" /></a>
        <button type="button" class="btn btn--ghost" @click="palette.open()"><UiIcon name="search" :size="16" /> Search instead</button>
      </div>
    </div>

    <article v-else-if="page">
      <header class="hero container">
        <nav class="crumbs" aria-label="Breadcrumb">
          <ol role="list">
            <li v-for="(c, i) in page.breadcrumb" :key="i">
              <SmartLink v-if="c.path && i < page.breadcrumb.length - 1" :href="c.path">{{ c.label }}</SmartLink>
              <span v-else aria-current="page">{{ c.label }}</span>
            </li>
          </ol>
        </nav>

        <div class="hero-grid">
          <div>
            <p v-if="programme" class="eyebrow accent">{{ levelLabels[programme.level] }} programme</p>
            <p v-else class="eyebrow">{{ page.section }}</p>
            <h1 class="title">{{ page.title }}</h1>
            <p v-if="page.description" class="lede">{{ page.description }}</p>
          </div>
          <div class="hero-meta">
            <SmartLink v-for="c in page.ctas" :key="c.href" :href="c.href" class="btn" :class="{ 'btn--signal': c === page.ctas[0], 'btn--ghost': c !== page.ctas[0] }">
              {{ c.label }} <UiIcon name="arrow-right" :size="16" />
            </SmartLink>
            <div class="meta-row">
              <RouterLink v-if="otherLang" :to="otherLang.href" class="chip"><UiIcon name="language" :size="14" /> {{ otherLang.label }}</RouterLink>
              <span v-if="page.lang === 'it'" class="chip chip--solid">In Italian</span>
              <a :href="page.source" class="chip" target="_blank" rel="noopener">Original <UiIcon name="arrow-up-right" :size="12" /></a>
            </div>
          </div>
        </div>

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
          <p v-else-if="!childPages.length" class="lede">This page is mostly a directory on the original site — see the links alongside.</p>

          <section v-if="childPages.length" class="children" aria-labelledby="in-section">
            <h2 id="in-section" class="sub-title">In this section</h2>
            <div class="grid">
              <PageCard v-for="c in childPages" :key="c.id" :entry="c" />
            </div>
          </section>
        </div>

        <aside class="side">
          <div class="sticky">
            <nav v-if="toc.length > 1" class="side-block" aria-label="On this page">
              <p class="side-title">On this page</p>
              <ul role="list">
                <li v-for="t in toc" :key="t"><a :href="`#${slugify(t)}`">{{ t }}</a></li>
              </ul>
            </nav>
            <nav v-if="page.nav.length" class="side-block" aria-label="Section">
              <p class="side-title">In this programme</p>
              <ul role="list">
                <li v-for="n in page.nav" :key="n.href">
                  <SmartLink :href="n.href" :class="{ current: n.href === page.path }">{{ n.label }}</SmartLink>
                </li>
              </ul>
            </nav>
            <nav v-if="page.links.length" class="side-block" aria-label="Quick links">
              <p class="side-title">Quick links</p>
              <ul role="list">
                <li v-for="l in page.links" :key="l.href">
                  <SmartLink :href="l.href">{{ l.label }} <UiIcon name="arrow-up-right" :size="12" /></SmartLink>
                </li>
              </ul>
            </nav>
            <p class="synced">Synced from usi.ch · {{ updated }}</p>
          </div>
        </aside>
      </div>

      <section v-if="siblingPages.length" class="container related" aria-labelledby="related">
        <h2 id="related" class="sub-title">Related pages</h2>
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
