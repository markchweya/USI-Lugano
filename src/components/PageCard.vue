<script setup lang="ts">
import type { PageEntry } from '@/content/types'
import UiIcon from './ui/UiIcon.vue'
import { useI18n } from '@/i18n'

defineProps<{ entry: PageEntry; showSection?: boolean }>()
const { m } = useI18n()
</script>

<template>
  <article class="pc">
    <div v-if="entry.image" class="pc-media">
      <img :src="entry.image" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
    </div>
    <div class="pc-body">
      <p v-if="showSection && entry.crumbs.length" class="pc-section">{{ entry.crumbs.join(' › ') }}</p>
      <h3 class="pc-title">
        <RouterLink :to="entry.path" class="pc-link">{{ entry.title }}</RouterLink>
      </h3>
      <p v-if="entry.description" class="pc-desc">{{ entry.description }}</p>
      <p class="pc-foot">
        <span v-if="entry.translated" class="chip">{{ m.programme.translated }}</span>
        <span class="pc-go"><UiIcon name="arrow-right" :size="16" /></span>
      </p>
    </div>
  </article>
</template>

<style scoped>
.pc {
  position: relative;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: var(--surface);
  transition:
    transform var(--dur) var(--ease-out),
    box-shadow var(--dur) var(--ease-out),
    border-color var(--dur);
}
.pc:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow);
  border-color: var(--line-strong);
}
.pc:focus-within {
  outline: 2px solid var(--signal);
  outline-offset: 2px;
}
.pc-media {
  aspect-ratio: 16 / 9;
  overflow: hidden;
  background: var(--paper-2);
}
.pc-media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 700ms var(--ease-out);
}
.pc:hover .pc-media img {
  transform: scale(1.05);
}
.pc-body {
  display: flex;
  flex-direction: column;
  flex: 1;
  gap: 0.5rem;
  padding: 1.1rem 1.2rem 1rem;
}
.pc-section {
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  color: var(--ink-3);
}
.pc-title {
  font-size: var(--step-1);
  line-height: 1.2;
}
.pc-link {
  text-decoration: none;
}
.pc-link:focus-visible {
  outline: none;
}
.pc-link::after {
  content: '';
  position: absolute;
  inset: 0;
}
.pc-desc {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  font-size: 0.88rem;
  line-height: 1.5;
  color: var(--ink-2);
}
.pc-foot {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: auto;
  padding-top: 0.5rem;
}
.pc-go {
  margin-left: auto;
  color: var(--ink-3);
  transition:
    transform var(--dur) var(--ease-out),
    color var(--dur);
}
.pc:hover .pc-go {
  transform: translateX(4px);
  color: var(--signal);
}
</style>
