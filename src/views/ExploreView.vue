<script setup lang="ts">
import { computed, ref, shallowRef, watch } from 'vue'
import { loadIndex } from '@/content/api'
import { sections } from '@/content/nav'
import type { PageEntry } from '@/content/types'
import { search } from '@/lib/search'
import { useQueryState } from '@/composables/useQueryState'
import PageCard from '@/components/PageCard.vue'
import UiIcon from '@/components/ui/UiIcon.vue'

const PAGE_SIZE = 48

const entries = shallowRef<PageEntry[]>([])
const failed = ref(false)
loadIndex()
  .then((e) => (entries.value = e))
  .catch(() => (failed.value = true))

const section = useQueryState('section')
const q = useQueryState('q')
const lang = useQueryState('lang')
const qInput = ref(q.value)
let t: number | undefined
watch(qInput, (v) => {
  window.clearTimeout(t)
  t = window.setTimeout(() => (q.value = v.trim()), 200)
})

const limit = ref(PAGE_SIZE)
watch([section, q, lang], () => (limit.value = PAGE_SIZE))

const sectionOf = (e: PageEntry) => sections.find((s) => e.path.startsWith(`${s.root}/`) || e.path === s.root)?.key ?? 'other'

const tabs = computed(() => [
  { key: '', label: 'Everything', count: entries.value.length },
  ...sections.map((s) => ({ key: s.key, label: s.label, count: entries.value.filter((e) => sectionOf(e) === s.key).length })),
  { key: 'other', label: 'Other', count: entries.value.filter((e) => sectionOf(e) === 'other').length },
])

const filtered = computed(() => {
  let list = entries.value.filter((e) => (!section.value || sectionOf(e) === section.value) && (!lang.value || e.lang === lang.value))
  if (q.value) {
    const ranked = search(
      list.map((e) => ({ id: e.id, title: e.title, subtitle: e.crumbs.join(' '), group: '', to: e.path, keywords: e.description })),
      q.value,
      1000,
    )
    const byId = new Map(list.map((e) => [e.id, e]))
    list = ranked.map((r) => byId.get(r.id)!).filter(Boolean)
  }
  return list
})
const visible = computed(() => filtered.value.slice(0, limit.value))

const totalWords = computed(() => entries.value.reduce((n, e) => n + e.words, 0))
</script>

<template>
  <div class="explore">
    <header class="container head">
      <p class="eyebrow">Explore</p>
      <h1 class="title">
        <span class="num">{{ entries.length ? entries.length.toLocaleString('en') : '…' }}</span> real pages,
        <span class="serif-accent">one calm interface.</span>
      </h1>
      <p class="lede">
        Every public page we mirrored from usi.ch, about {{ Math.round(totalWords / 1000).toLocaleString('en') }}k words, organised and searchable. Pick a
        topic or start typing.
      </p>
    </header>

    <div class="container controls">
      <div class="search">
        <UiIcon name="search" :size="18" />
        <input v-model="qInput" type="search" placeholder="Filter pages — housing, scholarships, regulations…" aria-label="Filter pages" />
      </div>
      <div class="tabs" role="tablist" aria-label="Sections">
        <button
          v-for="tab in tabs"
          :key="tab.key"
          type="button"
          role="tab"
          class="tab"
          :aria-selected="section === tab.key"
          @click="section = tab.key"
        >
          {{ tab.label }} <span class="count">{{ tab.count }}</span>
        </button>
      </div>
      <div class="langs" role="group" aria-label="Language">
        <button type="button" class="tab" :aria-pressed="!lang" @click="lang = ''">All languages</button>
        <button type="button" class="tab" :aria-pressed="lang === 'en'" @click="lang = 'en'">English</button>
        <button type="button" class="tab" :aria-pressed="lang === 'it'" @click="lang = 'it'">Italiano</button>
      </div>
    </div>

    <section class="container" aria-live="polite">
      <p v-if="failed" class="empty">The page index couldn’t be loaded. Please refresh.</p>
      <template v-else>
        <p class="result-count">{{ filtered.length.toLocaleString('en') }} pages</p>
        <div class="grid">
          <PageCard v-for="e in visible" :key="e.id" :entry="e" show-section />
        </div>
        <div v-if="filtered.length > limit" class="more">
          <button type="button" class="btn btn--ghost" @click="limit += PAGE_SIZE">
            Show more <span class="count">({{ (filtered.length - limit).toLocaleString('en') }} left)</span>
          </button>
        </div>
        <p v-if="entries.length && !filtered.length" class="empty">No pages match. Try a broader term.</p>
      </template>
    </section>
  </div>
</template>

<style scoped>
.explore {
  padding-top: clamp(2rem, 5vw, 4rem);
}
.title {
  margin-top: 1rem;
  font-size: var(--step-5);
  max-width: 16ch;
}
.num {
  font-variant-numeric: tabular-nums;
}
.lede {
  max-width: 60ch;
  margin-top: 1.5rem;
  font-size: var(--step-1);
  color: var(--ink-2);
}
.controls {
  position: sticky;
  top: 0;
  z-index: 5;
  display: grid;
  gap: 0.9rem;
  margin-block: clamp(2rem, 4vw, 3rem) 1.5rem;
  padding-block: 1rem;
  background: color-mix(in oklab, var(--paper) 90%, transparent);
  backdrop-filter: blur(12px);
}
.search {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  height: 54px;
  padding: 0 1.1rem;
  border: 1px solid var(--line-strong);
  border-radius: 16px;
  background: var(--surface);
  color: var(--ink-3);
}
.search:focus-within {
  border-color: var(--ink);
}
.search input {
  flex: 1;
  min-width: 0;
  border: 0;
  outline: 0;
  background: none;
  color: var(--ink);
  font-size: 1.05rem;
}
.tabs,
.langs {
  display: flex;
  gap: 0.4rem;
  overflow-x: auto;
  scrollbar-width: none;
}
.tab {
  flex: none;
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.45rem 0.9rem;
  border: 1px solid var(--line-strong);
  border-radius: 999px;
  background: none;
  font-size: 0.88rem;
  font-weight: 500;
}
.tab[aria-selected='true'],
.tab[aria-pressed='true'] {
  background: var(--ink);
  border-color: var(--ink);
  color: var(--paper);
}
.langs .tab {
  font-size: 0.8rem;
  padding: 0.3rem 0.75rem;
}
.count {
  font-family: var(--font-mono);
  font-size: 0.72rem;
  opacity: 0.6;
}
.result-count {
  margin-bottom: 1rem;
  color: var(--ink-3);
  font-size: 0.9rem;
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 280px), 1fr));
  gap: 1rem;
}
.more {
  display: flex;
  justify-content: center;
  margin-top: 2.5rem;
}
.empty {
  padding: 3rem 0;
  color: var(--ink-2);
}
</style>
