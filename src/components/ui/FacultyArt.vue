<script setup lang="ts">
import { computed } from 'vue'
import type { ArtVariant } from '@/types'

/**
 * Deterministic generative artwork — each faculty has a visual signature
 * instead of a stock photo. Pure SVG, so it is crisp, tiny and theme-aware.
 */
const props = withDefaults(defineProps<{ variant: ArtVariant; color: string; seed?: number; animated?: boolean }>(), {
  seed: 1,
  animated: true,
})

// Small seeded PRNG (mulberry32) so artwork is stable across renders.
function rng(seed: number) {
  let a = seed * 9973
  return () => {
    a |= 0
    a = (a + 0x6d2b79f5) | 0
    let t = Math.imul(a ^ (a >>> 15), 1 | a)
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296
  }
}

const W = 400
const H = 300

interface Shapes {
  pts: { x: number; y: number; r: number }[]
  links: [number, number, number, number][]
  cells: { x: number; y: number; r: number; o: number }[]
  bars: { x: number; h: number }[]
  line: string
  waves: string[]
  arches: number[]
  cols: number[]
  blocks: { x: number; y: number; w: number; h: number }[]
}

const shapes = computed<Shapes>(() => {
  const r = rng(props.seed)
  const s: Shapes = { pts: [], links: [], cells: [], bars: [], line: '', waves: [], arches: [], cols: [], blocks: [] }

  switch (props.variant) {
    case 'nodes':
      s.pts = Array.from({ length: 22 }, () => ({ x: 20 + r() * (W - 40), y: 20 + r() * (H - 40), r: 2 + r() * 4 }))
      s.pts.forEach((a, i) =>
        s.pts.slice(i + 1).forEach((b) => {
          if (Math.hypot(a.x - b.x, a.y - b.y) < 110) s.links.push([a.x, a.y, b.x, b.y])
        }),
      )
      break
    case 'cells':
      s.cells = Array.from({ length: 14 }, () => ({ x: r() * W, y: r() * H, r: 14 + r() * 46, o: 0.15 + r() * 0.5 }))
      break
    case 'bars':
      s.bars = Array.from({ length: 16 }, (_, i) => ({ x: 16 + i * 24, h: 40 + r() * 190 }))
      s.line = Array.from({ length: 16 }, (_, i) => `${23 + i * 24},${230 - i * 9 - r() * 40}`).join(' ')
      break
    case 'waves':
      s.waves = Array.from({ length: 9 }, (_, i) => {
        const y = 40 + i * 28
        const a = 12 + r() * 26
        return `M-20 ${y} C 80 ${y - a}, 140 ${y + a}, 220 ${y} S 360 ${y - a}, 440 ${y}`
      })
      break
    case 'arches':
      s.arches = Array.from({ length: 7 }, (_, i) => 30 + i * 26)
      break
    case 'grid':
      s.cols = Array.from({ length: 11 }, (_, i) => i * 40)
      s.blocks = Array.from({ length: 5 }, () => ({
        x: Math.floor(r() * 9) * 40,
        y: Math.floor(r() * 6) * 40,
        w: 40 + Math.floor(r() * 3) * 40,
        h: 40 + Math.floor(r() * 2) * 40,
      }))
      break
  }
  return s
})
</script>

<template>
  <svg
    class="art"
    :class="{ 'art--animated': animated }"
    :viewBox="`0 0 ${W} ${H}`"
    preserveAspectRatio="xMidYMid slice"
    aria-hidden="true"
    :style="{ '--c': color }"
  >
    <rect :width="W" :height="H" class="bg" />

    <g v-if="variant === 'nodes'" class="fg">
      <line v-for="(l, i) in shapes.links" :key="`l${i}`" :x1="l[0]" :y1="l[1]" :x2="l[2]" :y2="l[3]" class="stroke thin" />
      <circle v-for="(p, i) in shapes.pts" :key="`p${i}`" :cx="p.x" :cy="p.y" :r="p.r" class="fill pulse" :style="{ animationDelay: `${i * 120}ms` }" />
    </g>

    <g v-else-if="variant === 'cells'" class="fg">
      <circle v-for="(c, i) in shapes.cells" :key="i" :cx="c.x" :cy="c.y" :r="c.r" class="cell drift" :style="{ opacity: c.o, animationDelay: `${i * -700}ms` }" />
    </g>

    <g v-else-if="variant === 'bars'" class="fg">
      <rect v-for="(b, i) in shapes.bars" :key="i" :x="b.x" :y="H - b.h" width="14" :height="b.h" rx="3" class="fill soft grow" :style="{ animationDelay: `${i * 50}ms` }" />
      <polyline :points="shapes.line" class="stroke bold" />
    </g>

    <g v-else-if="variant === 'waves'" class="fg">
      <path v-for="(d, i) in shapes.waves" :key="i" :d="d" class="stroke flow" :style="{ animationDelay: `${i * -400}ms` }" />
    </g>

    <g v-else-if="variant === 'arches'" class="fg">
      <path
        v-for="(r, i) in shapes.arches"
        :key="i"
        :d="`M ${W / 2 - r * 1.4} ${H} V ${H - 60 - r} A ${r * 1.4} ${r * 1.4} 0 0 1 ${W / 2 + r * 1.4} ${H - 60 - r} V ${H}`"
        class="stroke"
      />
      <circle :cx="W / 2" :cy="70" r="16" class="fill pulse" />
    </g>

    <g v-else class="fg">
      <line v-for="x in shapes.cols" :key="`c${x}`" :x1="x" y1="0" :x2="x" :y2="H" class="stroke thin" />
      <line v-for="y in [0, 40, 80, 120, 160, 200, 240, 280]" :key="`r${y}`" x1="0" :y1="y" :x2="W" :y2="y" class="stroke thin" />
      <rect v-for="(b, i) in shapes.blocks" :key="i" :x="b.x" :y="b.y" :width="b.w" :height="b.h" class="fill soft grow" :style="{ animationDelay: `${i * 160}ms` }" />
    </g>
  </svg>
</template>

<style scoped>
.art {
  width: 100%;
  height: 100%;
}
.bg {
  fill: color-mix(in oklab, var(--c) 12%, var(--surface));
}
.fill {
  fill: var(--c);
}
.soft {
  fill: color-mix(in oklab, var(--c) 55%, transparent);
}
.cell {
  fill: none;
  stroke: var(--c);
  stroke-width: 1.5;
}
.stroke {
  fill: none;
  stroke: var(--c);
  stroke-width: 1.5;
  stroke-linecap: round;
}
.thin {
  stroke-width: 0.75;
  opacity: 0.45;
}
.bold {
  stroke-width: 3;
}

.art--animated .pulse {
  animation: pulse 3.2s var(--ease-in-out) infinite;
  transform-box: fill-box;
  transform-origin: center;
}
.art--animated .drift {
  animation: drift 14s var(--ease-in-out) infinite alternate;
}
.art--animated .flow {
  stroke-dasharray: 6 10;
  animation: flow 6s linear infinite;
}
.art--animated .grow {
  animation: grow 1.2s var(--ease-out) both;
  transform-box: fill-box;
  transform-origin: bottom;
}

@keyframes pulse {
  50% {
    transform: scale(1.35);
    opacity: 0.6;
  }
}
@keyframes drift {
  to {
    transform: translate(14px, -10px);
  }
}
@keyframes flow {
  to {
    stroke-dashoffset: -160;
  }
}
@keyframes grow {
  from {
    transform: scaleY(0);
  }
}
</style>
