<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { programmes, levelLabels } from '@/data/programmes'
import { faculties } from '@/data/faculties'
import { search } from '@/lib/search'
import { useQueryState } from '@/composables/useQueryState'
import ProgrammeCard from '@/components/ProgrammeCard.vue'
import UiIcon from '@/components/ui/UiIcon.vue'
import type { Level } from '@/content/types'

const level = useQueryState('level')
const faculty = useQueryState('faculty')
const lang = useQueryState('lang')
const q = useQueryState('q')
const view = useQueryState('view', 'grid')

// Debounce typing into the URL; the input stays snappy.
const qInput = ref(q.value)
let t: number | undefined
watch(qInput, (v) => {
  window.clearTimeout(t)
  t = window.setTimeout(() => (q.value = v.trim()), 200)
})
watch(q, (v) => {
  if (v !== qInput.value.trim()) qInput.value = v
})

const levels = computed(() =>
  (Object.keys(levelLabels) as Level[])
    .map((l) => ({ id: l, label: levelLabels[l], count: programmes.filter((p) => p.level === l).length }))
    .filter((l) => l.count > 0),
)
const facultyOptions = computed(() =>
  faculties.map((f) => ({ ...f, count: programmes.filter((p) => p.faculty === f.slug).length })).filter((f) => f.count > 0),
)

const filtered = computed(() => {
  let list = programmes.filter(
    (p) => (!level.value || p.level === level.value) && (!faculty.value || p.faculty === faculty.value) && (!lang.value || p.languages.includes(lang.value as 'EN' | 'IT')),
  )
  if (q.value) {
    const ids = new Set(
      search(
        list.map((p) => ({ id: p.id, title: p.fullTitle, subtitle: p.summary, group: '', to: p.path })),
        q.value,
        200,
      ).map((r) => r.id),
    )
    list = list.filter((p) => ids.has(p.id))
  }
  return list
})

const activeCount = computed(() => [level.value, faculty.value, lang.value, q.value].filter(Boolean).length)
function reset() {
  level.value = ''
  faculty.value = ''
  lang.value = ''
  qInput.value = ''
  q.value = ''
}
const filtersOpen = ref(false)
</script>

<template>
  <div class="study">
    <header class="container head">
      <p class="eyebrow">Programme finder</p>
      <h1 class="title">Find the programme <span class="serif-accent">that fits you.</span></h1>
      <p class="lede">Every Bachelor and Master currently published on usi.ch, in one place. Filter by level, faculty or teaching language — your selection lives in the URL, so you can share it.</p>
    </header>

    <div class="container layout">
      <button type="button" class="btn btn--ghost filters-toggle" :aria-expanded="filtersOpen" aria-controls="filters" @click="filtersOpen = !filtersOpen">
        <UiIcon name="filter" :size="16" /> Filters<span v-if="activeCount"> ({{ activeCount }})</span>
      </button>

      <aside id="filters" class="filters" :class="{ open: filtersOpen }" aria-label="Filters">
        <div class="field">
          <label for="q" class="label">Search</label>
          <div class="search">
            <UiIcon name="search" :size="16" />
            <input id="q" v-model="qInput" type="search" placeholder="e.g. finance, AI, architecture" autocomplete="off" />
          </div>
        </div>

        <fieldset class="field">
          <legend class="label">Level</legend>
          <div class="chips">
            <button type="button" class="pill" :aria-pressed="!level" @click="level = ''">All</button>
            <button v-for="l in levels" :key="l.id" type="button" class="pill" :aria-pressed="level === l.id" @click="level = level === l.id ? '' : l.id">
              {{ l.label }} <span class="count">{{ l.count }}</span>
            </button>
          </div>
        </fieldset>

        <fieldset class="field">
          <legend class="label">Faculty</legend>
          <div class="radios">
            <label class="radio">
              <input v-model="faculty" type="radio" name="faculty" value="" />
              <span>All faculties</span>
            </label>
            <label v-for="f in facultyOptions" :key="f.slug" class="radio" :style="{ '--fac': f.color }">
              <input v-model="faculty" type="radio" name="faculty" :value="f.slug" />
              <span><i class="dot" />{{ f.short }}</span>
              <span class="count">{{ f.count }}</span>
            </label>
          </div>
        </fieldset>

        <fieldset class="field">
          <legend class="label">Taught in</legend>
          <div class="chips">
            <button type="button" class="pill" :aria-pressed="!lang" @click="lang = ''">Any</button>
            <button type="button" class="pill" :aria-pressed="lang === 'EN'" @click="lang = lang === 'EN' ? '' : 'EN'">English</button>
            <button type="button" class="pill" :aria-pressed="lang === 'IT'" @click="lang = lang === 'IT' ? '' : 'IT'">Italian</button>
          </div>
        </fieldset>

        <button v-if="activeCount" type="button" class="reset" @click="reset">Clear all filters</button>
      </aside>

      <section class="results" aria-live="polite">
        <div class="toolbar">
          <p class="result-count">
            <strong>{{ filtered.length }}</strong> {{ filtered.length === 1 ? 'programme' : 'programmes' }}
          </p>
          <div class="view-switch" role="group" aria-label="Layout">
            <button type="button" :aria-pressed="view === 'grid'" @click="view = 'grid'"><UiIcon name="grid" :size="16" label="Grid view" /></button>
            <button type="button" :aria-pressed="view === 'list'" @click="view = 'list'"><UiIcon name="list" :size="16" label="List view" /></button>
          </div>
        </div>

        <TransitionGroup v-if="filtered.length" tag="div" name="list" class="grid" :class="{ 'grid--list': view === 'list' }">
          <ProgrammeCard v-for="p in filtered" :key="p.id" :programme="p" :layout="view === 'list' ? 'row' : 'card'" />
        </TransitionGroup>

        <div v-else class="empty">
          <p class="empty-title">Nothing matches those filters.</p>
          <p>Try removing one, or search the whole site with <kbd>/</kbd>.</p>
          <button type="button" class="btn btn--ghost btn--sm" @click="reset">Reset filters</button>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.study {
  padding-top: clamp(2rem, 5vw, 4rem);
}
.title {
  margin-top: 1rem;
  font-size: var(--step-5);
  max-width: 14ch;
}
.lede {
  max-width: 60ch;
  margin-top: 1.5rem;
  font-size: var(--step-1);
  color: var(--ink-2);
}
.layout {
  display: grid;
  gap: 2rem;
  margin-top: clamp(2.5rem, 5vw, 4rem);
}
@media (min-width: 1000px) {
  .layout {
    grid-template-columns: 280px 1fr;
    gap: 3rem;
    align-items: start;
  }
  .filters-toggle {
    display: none;
  }
}
.filters-toggle {
  justify-self: start;
}
.filters {
  display: none;
  gap: 1.75rem;
  padding: 1.5rem;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: var(--surface);
}
.filters.open {
  display: grid;
}
@media (min-width: 1000px) {
  .filters {
    display: grid;
    position: sticky;
    top: calc(var(--header-h) + 1.5rem);
  }
}
.field {
  display: grid;
  gap: 0.7rem;
  margin: 0;
  padding: 0;
  border: 0;
  min-width: 0;
}
.label {
  padding: 0;
  font-family: var(--font-mono);
  font-size: 0.7rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--ink-3);
}
.search {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  height: 44px;
  padding: 0 0.85rem;
  border: 1px solid var(--line-strong);
  border-radius: 12px;
  background: var(--paper);
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
}
.chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
}
.pill {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.45rem 0.85rem;
  border: 1px solid var(--line-strong);
  border-radius: 999px;
  background: none;
  font-size: 0.88rem;
  font-weight: 500;
  transition: all var(--dur) var(--ease-out);
}
.pill:hover {
  border-color: var(--ink);
}
.pill[aria-pressed='true'] {
  background: var(--ink);
  border-color: var(--ink);
  color: var(--paper);
}
.count {
  font-family: var(--font-mono);
  font-size: 0.72rem;
  opacity: 0.6;
}
.radios {
  display: grid;
  gap: 0.15rem;
}
.radio {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.45rem 0.6rem;
  margin-inline: -0.6rem;
  border-radius: 10px;
  cursor: pointer;
  font-size: 0.92rem;
}
.radio:hover {
  background: var(--paper-2);
}
.radio input {
  accent-color: var(--signal);
}
.radio span:first-of-type {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}
.radio .count {
  margin-left: auto;
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--fac);
}
.reset {
  justify-self: start;
  padding: 0;
  border: 0;
  background: none;
  color: var(--signal);
  font-weight: 600;
  text-decoration: underline;
}
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1.25rem;
}
.result-count {
  color: var(--ink-2);
}
.result-count strong {
  font-family: var(--font-display);
  font-size: var(--step-2);
  font-weight: 400;
  color: var(--ink);
}
.view-switch {
  display: flex;
  padding: 3px;
  border: 1px solid var(--line);
  border-radius: 999px;
}
.view-switch button {
  display: grid;
  place-items: center;
  width: 36px;
  height: 32px;
  border: 0;
  border-radius: 999px;
  background: none;
  color: var(--ink-3);
}
.view-switch button[aria-pressed='true'] {
  background: var(--ink);
  color: var(--paper);
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 300px), 1fr));
  gap: 1.25rem;
}
.grid--list {
  grid-template-columns: 1fr;
}
.empty {
  display: grid;
  gap: 0.75rem;
  justify-items: start;
  padding: 3rem 2rem;
  border: 1px dashed var(--line-strong);
  border-radius: var(--radius);
}
.empty-title {
  font-family: var(--font-display);
  font-size: var(--step-2);
}
kbd {
  padding: 0 0.35em;
  border: 1px solid var(--line-strong);
  border-radius: 4px;
  font-family: var(--font-mono);
  font-size: 0.8em;
}
.list-move,
.list-enter-active,
.list-leave-active {
  transition:
    opacity 300ms var(--ease-out),
    transform 300ms var(--ease-out);
}
.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: scale(0.97);
}
.list-leave-active {
  position: absolute;
  visibility: hidden;
}
</style>
