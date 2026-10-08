<script setup lang="ts">
import { ref } from 'vue'
import UiIcon from '../ui/UiIcon.vue'

/**
 * Click-to-load facade: no third-party requests or cookies until the visitor
 * chooses to play, and the privacy-enhanced youtube-nocookie domain after.
 */
const props = defineProps<{ id: string; title?: string }>()
const playing = ref(false)
const thumb = `https://i.ytimg.com/vi/${props.id}/hqdefault.jpg`
</script>

<template>
  <div class="yt">
    <iframe
      v-if="playing"
      :src="`https://www.youtube-nocookie.com/embed/${id}?autoplay=1&rel=0`"
      :title="title || 'Video'"
      allow="autoplay; encrypted-media; picture-in-picture; fullscreen"
      allowfullscreen
    />
    <button v-else type="button" class="poster" @click="playing = true">
      <img :src="thumb" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
      <span class="play"><svg viewBox="0 0 24 24" width="28" height="28" aria-hidden="true"><path d="M8 5v14l11-7z" fill="currentColor" /></svg></span>
      <span class="label"><UiIcon name="arrow-right" :size="14" /> Play video{{ title ? `: ${title}` : '' }}</span>
    </button>
  </div>
</template>

<style scoped>
.yt {
  position: relative;
  aspect-ratio: 16 / 9;
  overflow: hidden;
  border-radius: var(--radius);
  background: #000;
}
iframe,
.poster {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  border: 0;
}
.poster {
  padding: 0;
  background: none;
  color: #fff;
}
.poster img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.85;
  transition:
    transform 600ms var(--ease-out),
    opacity var(--dur);
}
.poster:hover img {
  transform: scale(1.03);
  opacity: 1;
}
.play {
  position: absolute;
  top: 50%;
  left: 50%;
  display: grid;
  place-items: center;
  width: 72px;
  height: 72px;
  margin: -36px 0 0 -36px;
  border-radius: 50%;
  background: var(--signal);
  color: var(--signal-ink);
  box-shadow: 0 10px 40px rgb(0 0 0 / 0.35);
  transition: transform var(--dur) var(--ease-out);
}
.poster:hover .play {
  transform: scale(1.08);
}
.label {
  position: absolute;
  left: 1rem;
  bottom: 1rem;
  display: inline-flex;
  align-items: center;
  gap: 0.4em;
  padding: 0.35em 0.8em;
  border-radius: 999px;
  background: rgb(0 0 0 / 0.55);
  backdrop-filter: blur(6px);
  font-size: 0.8rem;
  font-weight: 500;
}
</style>
