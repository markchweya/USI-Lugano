<script setup lang="ts">
import { computed, ref, shallowRef, watch } from 'vue'
import { entriesFor, loadIndex } from '@/content/api'
import { sectionKeys, sectionOf } from '@/content/nav'
import type { PageEntry } from '@/content/types'
import { search } from '@/lib/search'
import { useQueryState } from '@/composables/useQueryState'
import { useI18n } from '@/i18n'
import PageCard from '@/components/PageCard.vue'
import UiIcon from '@/components/ui/UiIcon.vue'

const PAGE_SIZE = 48

const { locale, m, n } = useI18n()
const all = shallowRef<PageEntry[]>([])
const failed = ref(false)
watch(
  locale,
  (l) => {
    failed.value = false
    loadIndex(l)
      .then((e) => {
        if (l === locale.value) all.value = e
      })
      .catch(() => (failed.value = true))
  },
  { immediate: true },
)

/** Pages in the current language only. */
const entries = computed(() => entriesFor(all.value, locale.value))

const section = useQueryState('section')
const q = useQueryState('q')
const qInput = ref(q.value)
let t: number | undefined
watch(qInput, (v) => {
  window.clearTimeout(t)
  t = window.setTimeout(() => (q.value = v.trim()), 200)
})

const limit = ref(PAGE_SIZE)
watch([section, q, locale], () => (limit.value = PAGE_SIZE))

const tabs = computed(() => [
  { key: '', label: m.value.explore.everything, count: entries.value.length },
  ...sectionKeys.map((k) => ({ key: k, label: m.value.sections[k].label, count: entries.value.filter((e) => sectionOf(e.path) === k).length })),
  { key: 'other', label: m.value.sections.other.label, count: entries.value.filter((e) => sectionOf(e.path) === 'other').length },
].filter((tab) => tab.key === '' || tab.count > 0))

const filtered = computed(() => {
  let list = entries.value.filter((e) => !section.value || sectionOf(e.path) === section.value)
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

const kWords = computed(() => n(Math.round(entries.value.reduce((s, e) => s + e.words, 0) / 1000)))
</script>

<template>
  <div class="explore">
    <header class="container head">
      <p class="eyebrow">{{ m.explore.eyebrow }}</p>
      <h1 class="title">
        <span class="num">{{ m.explore.headingA(entries.length ? n(entries.length) : '…') }}</span>
        <span class="serif-accent">{{ m.explore.headingB }}</span>
      </h1>
      <p class="lede">{{ m.explore.lede(kWords) }}</p>
    </header>

    <div class="container controls">
      <div class="search">
        <UiIcon name="search" :size="18" />
        <input v-model="qInput" type="search" :placeholder="m.explore.placeholder" :aria-label="m.explore.filter" />
      </div>
      <div class="tabs" role="tablist" :aria-label="m.explore.sections">
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

    </div>

    <section class="container" aria-live="polite" aria-labelledby="results-heading">
      <h2 id="results-heading" class="visually-hidden">{{ m.palette.results }}</h2>
      <p v-if="failed" class="empty">{{ m.explore.failed }}</p>
      <template v-else>
        <p class="result-count">{{ m.explore.count(n(filtered.length)) }}</p>
        <div class="grid">
          <PageCard v-for="e in visible" :key="e.id" :entry="e" show-section />
        </div>
        <div v-if="filtered.length > limit" class="more">
          <button type="button" class="btn btn--ghost" @click="limit += PAGE_SIZE">
            {{ m.explore.more }} <span class="count">{{ m.explore.left(n(filtered.length - limit)) }}</span>
          </button>
        </div>
        <p v-if="entries.length && !filtered.length" class="empty">{{ m.explore.empty }}</p>
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
.tabs {
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
