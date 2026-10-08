<script setup lang="ts">
import { ref } from 'vue'
import type { GalleryItem } from '@/content/types'
import YouTubeEmbed from './YouTubeEmbed.vue'
import UiIcon from '../ui/UiIcon.vue'

const props = defineProps<{ items: GalleryItem[] }>()
const track = ref<HTMLElement>()
const active = ref(0)

function go(i: number) {
  const el = track.value
  if (!el) return
  const n = Math.max(0, Math.min(props.items.length - 1, i))
  el.scrollTo({ left: n * el.clientWidth, behavior: 'smooth' })
}

function onScroll() {
  const el = track.value
  if (el) active.value = Math.round(el.scrollLeft / el.clientWidth)
}
</script>

<template>
  <div class="carousel" :class="{ single: items.length === 1 }" role="region" aria-roledescription="carousel" aria-label="Media">
    <div ref="track" class="track" tabindex="0" @scroll.passive="onScroll">
      <div v-for="(item, i) in items" :key="i" class="slide" :aria-label="`${i + 1} of ${items.length}`" role="group" aria-roledescription="slide">
        <YouTubeEmbed v-if="item.kind === 'video' && item.youtube" :id="item.youtube" :title="item.caption" />
        <img v-else :src="item.src" :alt="item.alt || ''" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
        <p v-if="item.caption && item.kind === 'image'" class="caption">{{ item.caption }}</p>
      </div>
    </div>
    <div v-if="items.length > 1" class="controls">
      <button type="button" class="ctrl" :disabled="active === 0" @click="go(active - 1)"><UiIcon name="arrow-left" :size="18" label="Previous" /></button>
      <span class="count">{{ active + 1 }} / {{ items.length }}</span>
      <button type="button" class="ctrl" :disabled="active === items.length - 1" @click="go(active + 1)"><UiIcon name="arrow-right" :size="18" label="Next" /></button>
    </div>
  </div>
</template>

<style scoped>
.carousel {
  position: relative;
}
.track {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scrollbar-width: none;
  border-radius: var(--radius);
}
.track::-webkit-scrollbar {
  display: none;
}
.slide {
  position: relative;
  flex: 0 0 100%;
  scroll-snap-align: start;
}
.slide > img {
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
  background: var(--paper-2);
}
.caption {
  position: absolute;
  left: 1rem;
  bottom: 1rem;
  padding: 0.3em 0.8em;
  border-radius: 999px;
  background: rgb(0 0 0 / 0.55);
  color: #fff;
  font-size: 0.8rem;
}
.controls {
  position: absolute;
  right: 1rem;
  bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.3rem;
  border-radius: 999px;
  background: rgb(10 15 21 / 0.6);
  backdrop-filter: blur(8px);
  color: #fff;
}
.ctrl {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border: 0;
  border-radius: 50%;
  background: rgb(255 255 255 / 0.12);
  color: inherit;
}
.ctrl:disabled {
  opacity: 0.35;
  cursor: default;
}
.count {
  min-width: 3.2em;
  text-align: center;
  font-family: var(--font-mono);
  font-size: 0.8rem;
}
</style>
