<script setup lang="ts">
import { useLuganoTime } from '@/composables/useLocalTime'

/**
 * Stylised Lake Lugano between Monte San Salvatore and Monte Brè.
 * Colours come from CSS variables, so the scene turns from dawn to night with the theme.
 */
const time = useLuganoTime()
const stars = Array.from({ length: 40 }, (_, i) => ({
  x: (i * 197) % 800,
  y: (i * 89) % 260,
  r: i % 5 === 0 ? 1.6 : 0.9,
  d: (i % 7) * 0.6,
}))
</script>

<template>
  <figure class="scene">
    <svg viewBox="0 0 800 600" preserveAspectRatio="xMidYMid slice" role="img" aria-label="Illustration of Lake Lugano between Monte San Salvatore and Monte Brè">
      <defs>
        <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="var(--sky-top)" />
          <stop offset="1" stop-color="var(--sky-bottom)" />
        </linearGradient>
        <linearGradient id="water" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stop-color="var(--water-top)" />
          <stop offset="1" stop-color="var(--water-bottom)" />
        </linearGradient>
        <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0" stop-color="var(--orb)" stop-opacity="0.55" />
          <stop offset="1" stop-color="var(--orb)" stop-opacity="0" />
        </radialGradient>
      </defs>

      <rect width="800" height="600" fill="url(#sky)" />
      <g class="stars">
        <circle v-for="(s, i) in stars" :key="i" :cx="s.x" :cy="s.y" :r="s.r" :style="{ animationDelay: `${s.d}s` }" />
      </g>
      <circle cx="560" cy="210" r="150" fill="url(#glow)" />
      <circle cx="560" cy="210" r="46" fill="var(--orb)" class="orb" />

      <!-- Far ridges -->
      <path d="M0 330 L90 280 L170 300 L260 250 L350 292 L440 262 L520 296 L610 248 L700 286 L800 262 L800 400 L0 400Z" fill="var(--mtn-3)" />
      <!-- Monte San Salvatore (left) and Monte Brè (right) -->
      <path d="M-20 400 L60 330 L140 250 Q170 214 196 248 L268 330 L330 400Z" fill="var(--mtn-2)" />
      <path d="M440 400 L520 330 L600 262 Q640 236 676 266 L760 320 L820 360 L820 400Z" fill="var(--mtn-2)" />
      <path d="M0 400 L120 360 L230 384 L300 400Z" fill="var(--mtn-1)" />
      <path d="M520 400 L640 352 L760 372 L820 400Z" fill="var(--mtn-1)" />

      <!-- Lake -->
      <rect y="398" width="800" height="202" fill="url(#water)" />
      <path d="M140 400 Q170 470 196 400" fill="var(--mtn-2)" opacity="0.18" />
      <path d="M600 400 Q640 450 676 400" fill="var(--mtn-2)" opacity="0.18" />
      <g class="ripples">
        <path v-for="i in 9" :key="i" :d="`M${(i * 83) % 700} ${410 + i * 20} h${70 + (i % 3) * 40}`" :style="{ animationDelay: `${i * -0.7}s` }" />
      </g>
      <path d="M560 404 L548 600 L572 600Z" fill="var(--orb)" opacity="0.18" class="reflection" />

      <!-- Labels -->
      <g class="labels">
        <text x="168" y="230" text-anchor="middle">San Salvatore · 912 m</text>
        <text x="640" y="246" text-anchor="middle">Monte Brè · 925 m</text>
      </g>
    </svg>
    <figcaption class="badge">
      <span class="live" aria-hidden="true" />
      Lugano <span class="sep">·</span> {{ time }} <span class="sep">·</span> 46.00° N, 8.95° E
    </figcaption>
  </figure>
</template>

<style scoped>
.scene {
  --sky-top: #f7d9c4;
  --sky-bottom: #fbeee4;
  --orb: #ff8a5b;
  --mtn-3: #c7c6cf;
  --mtn-2: #6f7f93;
  --mtn-1: #34485e;
  --water-top: #5d8aa2;
  --water-bottom: #1c5a73;
  --star: transparent;
  position: relative;
  margin: 0;
  overflow: hidden;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  isolation: isolate;
}
:global([data-theme='dark']) .scene {
  --sky-top: #05080f;
  --sky-bottom: #1b2a44;
  --orb: #f2e9d8;
  --mtn-3: #1f2c40;
  --mtn-2: #142032;
  --mtn-1: #0b1422;
  --water-top: #12223a;
  --water-bottom: #060b14;
  --star: #f2e9d8;
}
svg {
  width: 100%;
  height: 100%;
  aspect-ratio: 4 / 3;
}
.stars circle {
  fill: var(--star);
  animation: twinkle 3.5s ease-in-out infinite;
}
.orb {
  animation: rise 1.8s var(--ease-out) both;
}
.ripples path {
  stroke: rgb(255 255 255 / 0.35);
  stroke-width: 1.4;
  stroke-linecap: round;
  animation: drift 7s ease-in-out infinite alternate;
}
.reflection {
  animation: shimmer 4s ease-in-out infinite;
}
.labels text {
  fill: rgb(255 255 255 / 0.85);
  font-family: var(--font-mono);
  font-size: 11px;
  letter-spacing: 0.06em;
}
.badge {
  position: absolute;
  left: 1rem;
  bottom: 1rem;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
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
  box-shadow: 0 0 0 0 rgb(63 207 151 / 0.6);
  animation: ping 2s infinite;
}
@keyframes twinkle {
  50% {
    opacity: 0.25;
  }
}
@keyframes rise {
  from {
    transform: translateY(60px);
    opacity: 0;
  }
}
@keyframes drift {
  to {
    transform: translateX(24px);
  }
}
@keyframes shimmer {
  50% {
    opacity: 0.32;
  }
}
@keyframes ping {
  70% {
    box-shadow: 0 0 0 8px rgb(63 207 151 / 0);
  }
  100% {
    box-shadow: 0 0 0 0 rgb(63 207 151 / 0);
  }
}
</style>
