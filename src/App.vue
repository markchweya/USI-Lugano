<script setup lang="ts">
import { nextTick, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from '@/components/AppHeader.vue'
import AppFooter from '@/components/AppFooter.vue'
import CommandPalette from '@/components/CommandPalette.vue'
import { useTheme } from '@/composables/useTheme'

useTheme()

// Announce client-side navigations to screen readers and move focus to the content.
const route = useRoute()
const announcement = ref('')
const main = ref<HTMLElement>()
let first = true
watch(
  () => route.path,
  async () => {
    if (first) return void (first = false)
    await nextTick()
    setTimeout(() => {
      announcement.value = document.title
      main.value?.focus({ preventScroll: true })
    }, 120)
  },
)
</script>

<template>
  <a href="#main" class="skip-link">Skip to content</a>
  <AppHeader />
  <main id="main" ref="main" tabindex="-1">
    <RouterView v-slot="{ Component, route: r }">
      <Transition name="page" mode="out-in">
        <component :is="Component" :key="r.path" />
      </Transition>
    </RouterView>
  </main>
  <AppFooter />
  <CommandPalette />
  <p class="visually-hidden" aria-live="polite" aria-atomic="true">{{ announcement }}</p>
</template>

<style>
#main:focus {
  outline: none;
}
</style>
