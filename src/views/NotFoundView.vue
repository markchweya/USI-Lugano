<script setup lang="ts">
import { useCommandPalette } from '@/composables/useCommandPalette'
import UiIcon from '@/components/ui/UiIcon.vue'

const palette = useCommandPalette()
</script>

<template>
  <section class="container nf">
    <p class="code" aria-hidden="true">404</p>
    <h1>This path leads into the lake.</h1>
    <p class="lede">The page you’re looking for doesn’t exist here. Search for it, or head back to dry land.</p>
    <div class="actions">
      <button type="button" class="btn btn--signal" @click="palette.open()"><UiIcon name="search" :size="16" /> Search</button>
      <RouterLink to="/" class="btn btn--ghost">Back home</RouterLink>
    </div>
  </section>
</template>

<style scoped>
.nf {
  display: grid;
  gap: 1.25rem;
  justify-items: start;
  padding-block: var(--section);
}
.code {
  font-family: var(--font-display);
  font-size: clamp(6rem, 20vw, 14rem);
  line-height: 0.85;
  color: transparent;
  -webkit-text-stroke: 1.5px var(--signal);
}
h1 {
  font-size: var(--step-4);
}
.lede {
  max-width: 50ch;
  color: var(--ink-2);
  font-size: var(--step-1);
}
.actions {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.5rem;
}
</style>
