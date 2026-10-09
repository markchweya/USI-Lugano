<script setup lang="ts">
import { computed, nextTick, onBeforeUnmount, onMounted, ref, shallowRef, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useCommandPalette } from '@/composables/useCommandPalette'
import { useScrollLock } from '@/composables/useScrollLock'
import { search, type SearchEntry } from '@/lib/search'
import { buildSearchIndex, instantEntries } from '@/lib/searchIndex'
import { useI18n } from '@/i18n'
import UiIcon from './ui/UiIcon.vue'

const { isOpen, open, close } = useCommandPalette()
const router = useRouter()
useScrollLock(isOpen)

const query = ref('')
const active = ref(0)
const input = ref<HTMLInputElement>()
const list = ref<HTMLElement>()
const { locale, m, n } = useI18n()
const instant = computed(() => instantEntries(locale.value))
const corpus = shallowRef<SearchEntry[]>(instant.value)
const fullFor = ref<string | null>(null)
const loadingCorpus = ref(false)

const suggestions = computed(() => [
  ...instant.value.filter((e) => e.group === 'goto'),
  ...instant.value.filter((e) => e.group === 'programmes').slice(0, 6),
])

const groupLabel = (g: string) => m.value.palette.groups[g as keyof typeof m.value.palette.groups] ?? g

const results = computed(() => (query.value.trim() ? search(corpus.value, query.value, 40) : suggestions.value))

const grouped = computed(() => {
  const groups: { name: string; items: { entry: SearchEntry; index: number }[] }[] = []
  results.value.forEach((entry, index) => {
    let g = groups.find((x) => x.name === entry.group)
    if (!g) groups.push((g = { name: entry.group, items: [] }))
    g.items.push({ entry, index })
  })
  return groups
})

watch(results, () => (active.value = 0))

watch(isOpen, async (o) => {
  if (!o) return
  query.value = ''
  await nextTick()
  input.value?.focus()
  if (fullFor.value !== locale.value) {
    const l = locale.value
    corpus.value = instant.value
    loadingCorpus.value = true
    const full = await buildSearchIndex(l)
    if (l === locale.value) {
      corpus.value = full
      fullFor.value = l
    }
    loadingCorpus.value = false
  }
})

function go(entry: SearchEntry | undefined) {
  if (!entry) return
  close()
  router.push(entry.to)
}

function move(delta: number) {
  const n = results.value.length
  if (!n) return
  active.value = (active.value + delta + n) % n
  nextTick(() => list.value?.querySelector(`[data-index="${active.value}"]`)?.scrollIntoView({ block: 'nearest' }))
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'ArrowDown') {
    e.preventDefault()
    move(1)
  } else if (e.key === 'ArrowUp') {
    e.preventDefault()
    move(-1)
  } else if (e.key === 'Enter') {
    e.preventDefault()
    go(results.value[active.value])
  } else if (e.key === 'Escape') {
    e.preventDefault()
    close()
  } else if (e.key === 'Tab') {
    e.preventDefault() // keep focus inside the dialog
  }
}

function onGlobalKey(e: KeyboardEvent) {
  const typing = (e.target as HTMLElement)?.closest('input, textarea, select, [contenteditable]')
  if ((e.key === 'k' && (e.metaKey || e.ctrlKey)) || (e.key === '/' && !typing)) {
    e.preventDefault()
    isOpen.value ? close() : open()
  }
}

onMounted(() => window.addEventListener('keydown', onGlobalKey))
onBeforeUnmount(() => window.removeEventListener('keydown', onGlobalKey))

const pagesCount = computed(() => corpus.value.filter((e) => e.group === 'pages' || e.group === 'programmes').length)

function highlight(text: string): string {
  const esc = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  const tokens = query.value
    .trim()
    .split(/\s+/)
    .filter((t) => t.length > 1)
    .map((t) => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
  if (!tokens.length) return esc
  return esc.replace(new RegExp(`(${tokens.join('|')})`, 'gi'), '<mark>$1</mark>')
}
</script>

<template>
  <Teleport to="body">
    <Transition name="palette">
      <div v-if="isOpen" class="overlay" @mousedown.self="close">
        <div class="palette" role="dialog" aria-modal="true" :aria-label="m.palette.dialog">
          <div class="field">
            <UiIcon name="search" :size="20" />
            <input
              ref="input"
              v-model="query"
              type="text"
              role="combobox"
              aria-expanded="true"
              aria-controls="palette-results"
              aria-autocomplete="list"
              :aria-activedescendant="results.length ? `pr-${active}` : undefined"
              :placeholder="m.palette.placeholder"
              autocomplete="off"
              spellcheck="false"
              @keydown="onKeydown"
            />
            <button type="button" class="esc" @click="close">{{ m.palette.esc }}</button>
          </div>

          <div id="palette-results" ref="list" class="results" role="listbox" :aria-label="m.palette.results">
            <template v-if="results.length">
              <div v-for="g in grouped" :key="g.name" role="group" :aria-label="groupLabel(g.name)">
                <p class="group">{{ query.trim() ? groupLabel(g.name) : g.name === 'goto' ? m.palette.jumpTo : m.palette.popular }}</p>
                <div
                  v-for="{ entry, index } in g.items"
                  :id="`pr-${index}`"
                  :key="entry.id"
                  :data-index="index"
                  class="item"
                  :class="{ active: index === active }"
                  role="option"
                  :aria-selected="index === active"
                  @mousemove="active = index"
                  @click="go(entry)"
                >
                  <span class="item-icon">
                    <UiIcon :name="entry.group === 'programmes' ? 'cap' : entry.group === 'goto' ? 'sparkle' : 'book'" :size="16" />
                  </span>
                  <span class="item-text">
                    <span class="item-title" v-html="highlight(entry.title)" />
                    <span class="item-sub">{{ entry.subtitle }}</span>
                  </span>
                  <UiIcon name="enter" :size="16" class="item-enter" />
                </div>
              </div>
            </template>
            <div v-else class="empty">
              <p>{{ m.palette.noResults(query) }}</p>
              <p class="muted">{{ m.palette.noResultsHint }}</p>
            </div>
          </div>

          <footer class="foot">
            <span><kbd>↑</kbd><kbd>↓</kbd> {{ m.palette.navigate }}</span>
            <span><kbd>↵</kbd> {{ m.palette.open }}</span>
            <span class="muted">{{ loadingCorpus ? m.palette.loadingIndex : m.palette.indexed(n(pagesCount)) }}</span>
          </footer>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  z-index: 150;
  display: grid;
  justify-items: center;
  align-items: start;
  padding: min(12vh, 120px) 1rem 1rem;
  background: rgb(10 15 21 / 0.45);
  backdrop-filter: blur(6px);
}
.palette {
  display: flex;
  flex-direction: column;
  width: min(680px, 100%);
  max-height: min(620px, 78dvh);
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: 20px;
  background: var(--surface-raised);
  box-shadow: var(--shadow-lg);
}
.field {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0 1.1rem;
  border-bottom: 1px solid var(--line);
  color: var(--ink-3);
}
.field input {
  flex: 1;
  min-width: 0;
  height: 62px;
  border: 0;
  outline: 0;
  background: none;
  color: var(--ink);
  font-size: 1.1rem;
}
.esc {
  padding: 0.25rem 0.5rem;
  border: 1px solid var(--line);
  border-radius: 6px;
  background: none;
  color: var(--ink-3);
  font-family: var(--font-mono);
  font-size: 0.72rem;
}
.results {
  flex: 1;
  overflow-y: auto;
  padding: 0.5rem;
  overscroll-behavior: contain;
}
.group {
  padding: 0.75rem 0.75rem 0.35rem;
  font-family: var(--font-mono);
  font-size: 0.7rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--ink-3);
}
.item {
  display: flex;
  align-items: center;
  gap: 0.85rem;
  padding: 0.6rem 0.75rem;
  border-radius: 12px;
  cursor: pointer;
}
.item.active {
  background: var(--paper-2);
}
.item-icon {
  display: grid;
  place-items: center;
  flex: none;
  width: 34px;
  height: 34px;
  border-radius: 10px;
  background: var(--paper);
  border: 1px solid var(--line);
  color: var(--ink-2);
}
.item.active .item-icon {
  background: var(--signal);
  border-color: transparent;
  color: var(--signal-ink);
}
.item-text {
  display: grid;
  min-width: 0;
}
.item-title {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-weight: 500;
}
.item-title :deep(mark) {
  background: var(--signal-soft);
  color: inherit;
  border-radius: 3px;
}
.item-sub {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 0.8rem;
  color: var(--ink-3);
}
.item-enter {
  margin-left: auto;
  opacity: 0;
  color: var(--ink-3);
}
.item.active .item-enter {
  opacity: 1;
}
.empty {
  padding: 2.5rem 1rem;
  text-align: center;
}
.muted {
  color: var(--ink-3);
  font-size: 0.85rem;
}
.foot {
  display: flex;
  gap: 1.25rem;
  padding: 0.7rem 1.1rem;
  border-top: 1px solid var(--line);
  font-size: 0.75rem;
  color: var(--ink-3);
}
.foot .muted {
  margin-left: auto;
  font-size: 0.75rem;
}
kbd {
  display: inline-block;
  min-width: 1.5em;
  margin-right: 0.2em;
  padding: 0 0.3em;
  border: 1px solid var(--line);
  border-radius: 4px;
  font-family: var(--font-mono);
  font-size: 0.7rem;
  text-align: center;
}
@media (max-width: 560px) {
  .foot span:not(.muted) {
    display: none;
  }
}
.palette-enter-active,
.palette-leave-active {
  transition: opacity 200ms var(--ease-out);
}
.palette-enter-active .palette,
.palette-leave-active .palette {
  transition: transform 260ms var(--ease-out);
}
.palette-enter-from,
.palette-leave-to {
  opacity: 0;
}
.palette-enter-from .palette,
.palette-leave-to .palette {
  transform: translateY(-12px) scale(0.98);
}
</style>
