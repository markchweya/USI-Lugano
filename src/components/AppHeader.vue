<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useSiteNav } from '@/content/nav'
import { useCommandPalette } from '@/composables/useCommandPalette'
import { useScrollLock } from '@/composables/useScrollLock'
import { useProgrammes } from '@/data/programmes'
import { appPageOf, useI18n } from '@/i18n'
import ThemeToggle from './ui/ThemeToggle.vue'
import LanguageSwitcher from './ui/LanguageSwitcher.vue'
import UiIcon from './ui/UiIcon.vue'
import BrandMark from './ui/BrandMark.vue'

const route = useRoute()
const { m, path } = useI18n()
const { sections, children } = useSiteNav()
const programmes = useProgrammes()
const palette = useCommandPalette()

const openKey = ref<string | null>(null)
const drawerOpen = ref(false)
const scrolled = ref(false)
const hidden = ref(false)
const isMac = ref(false)

useScrollLock(drawerOpen)

let lastY = 0
function onScroll() {
  const y = window.scrollY
  scrolled.value = y > 8
  // Hide on scroll down, reveal on scroll up — but never while a menu is open.
  hidden.value = y > 480 && y > lastY && !openKey.value && !drawerOpen.value
  lastY = y
}

let hoverTimer: number | undefined
function hoverOpen(key: string) {
  window.clearTimeout(hoverTimer)
  hoverTimer = window.setTimeout(() => (openKey.value = key), openKey.value ? 0 : 120)
}
function hoverClose() {
  window.clearTimeout(hoverTimer)
  hoverTimer = window.setTimeout(() => (openKey.value = null), 180)
}
function toggle(key: string) {
  openKey.value = openKey.value === key ? null : key
}

function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    openKey.value = null
    drawerOpen.value = false
  }
}

onMounted(() => {
  isMac.value = /Mac|iPhone|iPad/.test(navigator.platform)
  window.addEventListener('scroll', onScroll, { passive: true })
  window.addEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  window.removeEventListener('scroll', onScroll)
  window.removeEventListener('keydown', onKey)
})

watch(
  () => route.fullPath,
  () => {
    openKey.value = null
    drawerOpen.value = false
  },
)

const activeSection = computed(
  () => sections.value.find((s) => route.path.startsWith(s.root))?.key ?? (appPageOf(route.path) === 'study' ? 'education' : null),
)
const openSection = computed(() => sections.value.find((s) => s.key === openKey.value))
const levelCounts = computed(() => ({
  bachelor: programmes.value.filter((p) => p.level === 'bachelor').length,
  master: programmes.value.filter((p) => p.level === 'master').length,
}))
</script>

<template>
  <header class="header" :class="{ scrolled, hidden, menu: !!openKey }" @mouseleave="hoverClose">
    <div class="bar container">
      <RouterLink :to="path('home')" class="brand" :aria-label="m.nav.home">
        <BrandMark />
      </RouterLink>

      <nav class="nav" :aria-label="m.nav.main">
        <ul role="list">
          <li v-for="s in sections" :key="s.key" @mouseenter="hoverOpen(s.key)">
            <button
              type="button"
              class="nav-btn"
              :class="{ active: activeSection === s.key }"
              :aria-expanded="openKey === s.key"
              :aria-controls="`mega-${s.key}`"
              @click="toggle(s.key)"
            >
              {{ s.label }}
              <UiIcon name="chevron-down" :size="14" class="chev" />
            </button>
          </li>
          <li @mouseenter="hoverClose">
            <RouterLink :to="path('explore')" class="nav-btn" active-class="active">{{ m.nav.explore }}</RouterLink>
          </li>
        </ul>
      </nav>

      <div class="actions">
        <button type="button" class="search-btn" @click="palette.open()">
          <UiIcon name="search" :size="16" />
          <span class="search-label">{{ m.nav.search }}</span>
          <kbd class="kbd">{{ isMac ? '⌘' : 'Ctrl' }} K</kbd>
        </button>
        <LanguageSwitcher />
        <ThemeToggle />
        <RouterLink :to="path('study')" class="btn btn--signal btn--sm cta">{{ m.nav.programmes }}</RouterLink>
        <button type="button" class="burger" :aria-expanded="drawerOpen" aria-controls="drawer" @click="drawerOpen = !drawerOpen">
          <UiIcon :name="drawerOpen ? 'close' : 'menu'" :size="22" />
          <span class="visually-hidden">{{ m.nav.menu }}</span>
        </button>
      </div>
    </div>

    <!-- Mega menu -->
    <Transition name="mega">
      <div v-if="openSection" :id="`mega-${openSection.key}`" class="mega" @mouseenter="hoverOpen(openSection.key)">
        <div class="mega-inner container">
          <div class="mega-intro">
            <p class="eyebrow">{{ openSection.label }}</p>
            <p class="mega-title">{{ openSection.blurb }}</p>
            <template v-if="openSection.key === 'education'">
              <RouterLink :to="path('study')" class="finder-card">
                <span class="finder-k">{{ m.nav.finderLabel }}</span>
                <span class="finder-v">{{ m.nav.finderCounts(levelCounts.bachelor, levelCounts.master) }}</span>
                <span class="finder-go">{{ m.nav.findYours }} <UiIcon name="arrow-right" :size="16" /></span>
              </RouterLink>
            </template>
            <RouterLink v-else :to="{ path: path('explore'), query: { section: openSection.key } }" class="mega-all">
              {{ m.nav.everythingIn(openSection.label) }} <UiIcon name="arrow-right" :size="16" />
            </RouterLink>
          </div>
          <ul class="mega-links" role="list">
            <li v-for="c in children[openSection.key]" :key="c.path">
              <RouterLink :to="c.path" class="mega-link">
                <span class="mega-link-title">{{ c.title }}</span>
                <span v-if="c.description" class="mega-link-desc">{{ c.description }}</span>
              </RouterLink>
            </li>
            <li v-if="!children[openSection.key]?.length" class="mega-empty">{{ m.nav.loading }}</li>
          </ul>
        </div>
      </div>
    </Transition>
  </header>
  <div v-if="openKey" class="scrim" aria-hidden="true" @click="openKey = null" />

  <!-- Mobile drawer -->
  <Transition name="drawer">
    <div v-if="drawerOpen" id="drawer" class="drawer" role="dialog" aria-modal="true" :aria-label="m.nav.menu">
      <div class="drawer-inner">
        <button type="button" class="drawer-search" @click="palette.open()">
          <UiIcon name="search" :size="18" /> {{ m.nav.searchMobile }}
        </button>
        <LanguageSwitcher variant="inline" class="drawer-langs" />
        <RouterLink :to="path('study')" class="drawer-top">{{ m.nav.findProgramme }} <UiIcon name="arrow-right" /></RouterLink>
        <RouterLink :to="path('explore')" class="drawer-top">{{ m.nav.exploreEverything }} <UiIcon name="arrow-right" /></RouterLink>
        <details v-for="s in sections" :key="s.key" class="drawer-group">
          <summary>{{ s.label }} <UiIcon name="chevron-down" :size="18" /></summary>
          <ul role="list">
            <li v-for="c in children[s.key]" :key="c.path">
              <RouterLink :to="c.path">{{ c.title }}</RouterLink>
            </li>
          </ul>
        </details>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
.header {
  position: sticky;
  top: 0;
  z-index: 50;
  transition:
    transform 380ms var(--ease-out),
    background-color var(--dur),
    box-shadow var(--dur);
}
.header.scrolled,
.header.menu {
  background: color-mix(in oklab, var(--paper) 82%, transparent);
  backdrop-filter: saturate(1.6) blur(16px);
  -webkit-backdrop-filter: saturate(1.6) blur(16px);
  box-shadow: 0 1px 0 var(--line);
}
.header.hidden {
  transform: translateY(-100%);
}
.bar {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  height: var(--header-h);
}
.brand {
  display: flex;
  align-items: center;
  color: var(--ink);
  text-decoration: none;
  flex: none;
}
.nav {
  display: none;
  margin-right: auto;
}
.nav ul {
  display: flex;
  gap: 0.25rem;
}
.nav-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.3rem;
  padding: 0.55rem 0.85rem;
  border: 0;
  border-radius: 999px;
  background: none;
  font-weight: 500;
  font-size: 0.95rem;
  color: var(--ink-2);
  text-decoration: none;
  transition:
    background-color var(--dur),
    color var(--dur);
}
.nav-btn:hover,
.nav-btn[aria-expanded='true'] {
  background: var(--paper-2);
  color: var(--ink);
}
.nav-btn.active {
  color: var(--ink);
  box-shadow: inset 0 -2px 0 var(--signal);
  border-radius: 0;
}
.chev {
  transition: transform var(--dur) var(--ease-out);
}
.nav-btn[aria-expanded='true'] .chev {
  transform: rotate(180deg);
}
.actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-left: auto;
}
.search-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.55rem;
  height: 40px;
  padding: 0 0.75rem;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: var(--surface);
  color: var(--ink-3);
  font-size: 0.9rem;
  transition: border-color var(--dur);
}
.search-btn:hover {
  border-color: var(--line-strong);
  color: var(--ink);
}
.search-label,
.kbd {
  display: none;
}
.kbd {
  padding: 0.1rem 0.4rem;
  border: 1px solid var(--line);
  border-radius: 6px;
  font-family: var(--font-mono);
  font-size: 0.7rem;
}
.cta {
  display: none;
}
.burger {
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  border: 0;
  border-radius: 999px;
  background: var(--ink);
  color: var(--paper);
}

@media (min-width: 640px) {
  .search-label {
    display: inline;
  }
  .cta {
    display: inline-flex;
  }
}
@media (min-width: 1080px) {
  .nav {
    display: block;
  }
  .burger {
    display: none;
  }
  .actions {
    margin-left: 0;
  }
  .search-btn {
    min-width: 200px;
  }
  .kbd {
    display: inline;
    margin-left: auto;
  }
}

/* Mega menu */
.mega {
  position: absolute;
  inset: 100% 0 auto;
  background: var(--paper);
  border-bottom: 1px solid var(--line);
  box-shadow: var(--shadow-lg);
  max-height: calc(100dvh - var(--header-h));
  overflow-y: auto;
}
.mega-inner {
  display: grid;
  grid-template-columns: minmax(240px, 1fr) 2.6fr;
  gap: 3rem;
  padding-block: 2.5rem 3rem;
}
.mega-title {
  margin: 0.9rem 0 1.5rem;
  font-family: var(--font-display);
  font-size: var(--step-2);
  line-height: 1.15;
}
.mega-all {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  font-weight: 600;
  text-decoration: none;
  color: var(--signal);
}
.finder-card {
  display: grid;
  gap: 0.35rem;
  padding: 1.25rem;
  border-radius: var(--radius);
  background: var(--ink);
  color: var(--paper);
  text-decoration: none;
  transition: transform var(--dur) var(--ease-out);
}
.finder-card:hover {
  transform: translateY(-2px);
}
.finder-k {
  font-family: var(--font-mono);
  font-size: 0.72rem;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  opacity: 0.7;
}
.finder-v {
  font-family: var(--font-display);
  font-size: var(--step-2);
}
.finder-go {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  margin-top: 0.5rem;
  color: var(--signal);
  font-weight: 600;
}
.mega-links {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
  gap: 0.25rem 1rem;
  align-content: start;
}
.mega-link {
  display: grid;
  gap: 0.15rem;
  padding: 0.7rem 0.8rem;
  border-radius: var(--radius-sm);
  text-decoration: none;
  transition: background-color var(--dur);
}
.mega-link:hover {
  background: var(--surface);
}
.mega-link-title {
  font-weight: 600;
  color: var(--ink);
}
.mega-link-desc {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  font-size: 0.82rem;
  line-height: 1.4;
  color: var(--ink-3);
}
.mega-empty {
  color: var(--ink-3);
}
.mega-enter-active,
.mega-leave-active {
  transition:
    opacity 220ms var(--ease-out),
    transform 220ms var(--ease-out);
}
.mega-enter-from,
.mega-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
.scrim {
  position: fixed;
  inset: 0;
  z-index: 40;
  background: rgb(10 15 21 / 0.25);
  backdrop-filter: blur(2px);
}

/* Drawer */
.drawer {
  position: fixed;
  inset: var(--header-h) 0 0;
  z-index: 45;
  overflow-y: auto;
  background: var(--paper);
}
.drawer-inner {
  display: grid;
  gap: 0.5rem;
  padding: 1rem var(--gutter) 3rem;
}
.drawer-search {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  height: 52px;
  padding: 0 1rem;
  margin-bottom: 0.75rem;
  border: 1px solid var(--line-strong);
  border-radius: 14px;
  background: var(--surface);
  color: var(--ink-3);
  text-align: left;
}
.drawer-langs {
  margin-bottom: 0.5rem;
}
.drawer-top,
.drawer-group summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
  border-bottom: 1px solid var(--line);
  font-family: var(--font-display);
  font-size: var(--step-2);
  text-decoration: none;
  cursor: pointer;
  list-style: none;
}
.drawer-group summary::-webkit-details-marker {
  display: none;
}
.drawer-group[open] summary .icon {
  transform: rotate(180deg);
}
.drawer-group ul {
  display: grid;
  gap: 0.15rem;
  padding: 0.75rem 0 1rem;
}
.drawer-group a {
  display: block;
  padding: 0.5rem 0;
  color: var(--ink-2);
  text-decoration: none;
}
.drawer-enter-active,
.drawer-leave-active {
  transition:
    opacity 260ms var(--ease-out),
    transform 260ms var(--ease-out);
}
.drawer-enter-from,
.drawer-leave-to {
  opacity: 0;
  transform: translateY(-12px);
}
</style>
