<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { useI18n } from '@/i18n'

/** Animates from 0 to `value` the first time it scrolls into view. */
const props = withDefaults(defineProps<{ value: number; plain?: boolean; duration?: number }>(), { duration: 1600 })
const el = ref<HTMLElement>()
const shown = ref(0)
let io: IntersectionObserver | null = null
let raf = 0

const { n: fmt } = useI18n()
const format = (n: number) => (props.plain ? String(n) : fmt(n))

function run() {
  if (matchMedia('(prefers-reduced-motion: reduce)').matches) return void (shown.value = props.value)
  const start = performance.now()
  const tick = (now: number) => {
    const p = Math.min(1, (now - start) / props.duration)
    shown.value = Math.round(props.value * (1 - Math.pow(1 - p, 4)))
    if (p < 1) raf = requestAnimationFrame(tick)
  }
  raf = requestAnimationFrame(tick)
}

onMounted(() => {
  if (typeof IntersectionObserver === 'undefined') return void (shown.value = props.value)
  io = new IntersectionObserver(([e]) => {
    if (e?.isIntersecting) {
      run()
      io?.disconnect()
    }
  })
  if (el.value) io.observe(el.value)
})
onBeforeUnmount(() => {
  io?.disconnect()
  cancelAnimationFrame(raf)
})
</script>

<template>
  <span ref="el" class="count-up">
    <span aria-hidden="true">{{ format(shown) }}</span>
    <span class="visually-hidden">{{ format(value) }}</span>
  </span>
</template>

<style scoped>
.count-up {
  font-variant-numeric: tabular-nums;
}
</style>
