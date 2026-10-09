<script setup lang="ts">
import { useLuganoTime } from '@/composables/useLocalTime'
import { useI18n } from '@/i18n'

/**
 * Campus West in Lugano, with Monte San Salvatore behind it — USI's own
 * press photography, served from usi.ch in the size each screen needs.
 */
const time = useLuganoTime()
const { m } = useI18n()

const base = 'https://www.usi.ch/sites/default/files/styles'
const file = 'public/storage/images/press-campus-lugano-web-03.jpg'
const srcset = [
  `${base}/usi_large/${file}?itok=FeQPQAuJ 1200w`,
  `${base}/usi_xlarge/${file}?itok=bp1R-wRA 1440w`,
  `${base}/usi_xxlarge/${file}?itok=OdyWM1sE 2880w`,
].join(', ')
const src = `${base}/usi_xlarge/${file}?itok=bp1R-wRA`
</script>

<template>
  <figure class="hero-photo">
    <img
      :src="src"
      :srcset="srcset"
      sizes="(min-width: 1000px) 46vw, 100vw"
      width="1440"
      height="810"
      :alt="m.home.scene.label"
      fetchpriority="high"
      decoding="async"
      referrerpolicy="no-referrer"
    />
    <figcaption class="caption">
      <span class="place">{{ m.home.scene.caption }}</span>
      <span class="credit">{{ m.home.scene.credit }}</span>
    </figcaption>
    <p class="badge" aria-hidden="true">
      <span class="live" />
      Lugano <span class="sep">·</span> {{ time }} <span class="sep">·</span> 46.00° N, 8.95° E
    </p>
  </figure>
</template>

<style scoped>
.hero-photo {
  position: relative;
  margin: 0;
  overflow: hidden;
  aspect-ratio: 4 / 3;
  border-radius: var(--radius-lg);
  background: var(--paper-2);
  box-shadow: var(--shadow-lg);
  isolation: isolate;
}
.hero-photo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  /* Keep Monte San Salvatore in frame on the 4:3 crop. */
  object-position: 52% 40%;
  animation: settle 2.4s var(--ease-out) both;
}
/* Legibility for the overlays without darkening the whole photo. */
.hero-photo::after {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 0;
  background: linear-gradient(to top, rgb(5 8 12 / 0.55), transparent 38%), linear-gradient(to bottom, rgb(5 8 12 / 0.28), transparent 22%);
  pointer-events: none;
}
.caption {
  position: absolute;
  top: 1rem;
  left: 1rem;
  right: 1rem;
  z-index: 1;
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  color: #fff;
  font-size: 0.78rem;
  text-shadow: 0 1px 8px rgb(0 0 0 / 0.35);
}
.place {
  font-family: var(--font-display);
  font-size: 1.05rem;
  font-style: italic;
}
.credit {
  font-family: var(--font-mono);
  font-size: 0.68rem;
  letter-spacing: 0.06em;
  opacity: 0.85;
}
.badge {
  position: absolute;
  left: 1rem;
  bottom: 1rem;
  z-index: 1;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0;
  padding: 0.45rem 0.85rem;
  border-radius: 999px;
  background: rgb(10 15 21 / 0.55);
  backdrop-filter: blur(10px);
  color: #fff;
  font-family: var(--font-mono);
  font-size: 0.72rem;
  letter-spacing: 0.04em;
}
.sep {
  opacity: 0.5;
}
.live {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #3fcf97;
  animation: ping 2s infinite;
}
@keyframes settle {
  from {
    transform: scale(1.08);
  }
}
@keyframes ping {
  70% {
    box-shadow: 0 0 0 8px rgb(63 207 151 / 0);
  }
  0% {
    box-shadow: 0 0 0 0 rgb(63 207 151 / 0.6);
  }
}
</style>
