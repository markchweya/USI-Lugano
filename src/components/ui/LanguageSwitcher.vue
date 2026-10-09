<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { appPageOf, appPath, locales, messages, useI18n, type Locale } from '@/i18n'
import { alternates } from '@/composables/useAlternates'
import UiIcon from './UiIcon.vue'

const props = withDefaults(defineProps<{ variant?: 'menu' | 'inline' }>(), { variant: 'menu' })

const route = useRoute()
const { locale, m } = useI18n()
const open = ref(false)
const root = ref<HTMLElement>()

/** Where each language lives for the current page: the true alternate, else that language's home. */
const targets = computed(() =>
  locales.map((l) => {
    const page = appPageOf(route.path)
    let to: string | { path: string; query: typeof route.query }
    if (page) to = { path: appPath(page, l), query: route.query }
    else if (alternates.value[l]) to = alternates.value[l]!
    else {
      to = appPath('home', l)
    }
    return { locale: l, name: messages[l].meta.languageName, to }
  }),
)

function onDocClick(e: MouseEvent) {
  if (open.value && root.value && !root.value.contains(e.target as Node)) open.value = false
}
function onKey(e: KeyboardEvent) {
  if (e.key === 'Escape') open.value = false
}
onMounted(() => {
  document.addEventListener('click', onDocClick)
  document.addEventListener('keydown', onKey)
})
onBeforeUnmount(() => {
  document.removeEventListener('click', onDocClick)
  document.removeEventListener('keydown', onKey)
})

const code = (l: Locale) => l.toUpperCase()
</script>

<template>
  <nav v-if="props.variant === 'inline'" class="inline" :aria-label="m.nav.language">
    <RouterLink
      v-for="t in targets"
      :key="t.locale"
      :to="t.to"
      :hreflang="t.locale"
      :lang="t.locale"
      class="inline-link"
      :class="{ active: t.locale === locale }"
      :aria-current="t.locale === locale ? 'true' : undefined"
    >
      {{ t.name }}
    </RouterLink>
  </nav>

  <div v-else ref="root" class="switcher">
    <button type="button" class="trigger" :aria-expanded="open" aria-haspopup="true" :title="m.nav.language" @click="open = !open">
      <UiIcon name="globe" :size="16" />
      <span class="code">{{ code(locale) }}</span>
      <span class="visually-hidden">{{ m.nav.language }}: {{ m.meta.languageName }}</span>
    </button>
    <Transition name="pop">
      <ul v-if="open" class="menu" role="list">
        <li v-for="t in targets" :key="t.locale">
          <RouterLink :to="t.to" :hreflang="t.locale" :lang="t.locale" class="item" :class="{ active: t.locale === locale }" @click="open = false">
            <span class="item-code">{{ code(t.locale) }}</span>
            <span class="item-name">{{ t.name }}</span>
            <UiIcon v-if="t.locale === locale" name="check" :size="16" class="item-check" />
          </RouterLink>
        </li>
      </ul>
    </Transition>
  </div>
</template>

<style scoped>
.switcher {
  position: relative;
}
.trigger {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  height: 40px;
  padding: 0 0.75rem;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: transparent;
  color: var(--ink);
  font-size: 0.82rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  transition: background-color var(--dur);
}
.trigger:hover,
.trigger[aria-expanded='true'] {
  background: var(--surface);
}
.menu {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 60;
  min-width: 190px;
  padding: 0.35rem;
  border: 1px solid var(--line);
  border-radius: 14px;
  background: var(--surface-raised);
  box-shadow: var(--shadow-lg);
}
.item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.55rem 0.7rem;
  border-radius: 10px;
  color: var(--ink-2);
  text-decoration: none;
  font-size: 0.92rem;
}
.item:hover {
  background: var(--paper-2);
  color: var(--ink);
}
.item.active {
  color: var(--ink);
  font-weight: 600;
}
.item-code {
  display: grid;
  place-items: center;
  width: 30px;
  height: 22px;
  border-radius: 6px;
  background: var(--paper-2);
  font-family: var(--font-mono);
  font-size: 0.7rem;
  letter-spacing: 0.06em;
}
.item.active .item-code {
  background: var(--signal);
  color: var(--signal-ink);
}
.item-check {
  margin-left: auto;
  color: var(--signal);
}
.pop-enter-active,
.pop-leave-active {
  transition:
    opacity 160ms var(--ease-out),
    transform 160ms var(--ease-out);
}
.pop-enter-from,
.pop-leave-to {
  opacity: 0;
  transform: translateY(-4px);
}

.inline {
  display: flex;
  gap: 0.25rem;
  flex-wrap: wrap;
}
.inline-link {
  padding: 0.45rem 0.9rem;
  border: 1px solid var(--line-strong);
  border-radius: 999px;
  font-size: 0.88rem;
  text-decoration: none;
  color: var(--ink-2);
}
.inline-link.active {
  background: var(--ink);
  border-color: var(--ink);
  color: var(--paper);
}
</style>
