<script setup lang="ts">
import { computed } from 'vue'
import { useTheme } from '@/composables/useTheme'
import UiIcon from './UiIcon.vue'

const { preference, cycle } = useTheme()

const meta = computed(() => {
  switch (preference.value) {
    case 'light':
      return { icon: 'sun', label: 'Light theme' } as const
    case 'dark':
      return { icon: 'moon', label: 'Dark theme' } as const
    default:
      return { icon: 'monitor', label: 'System theme' } as const
  }
})
</script>

<template>
  <button type="button" class="theme-toggle" :title="`${meta.label} — click to change`" @click="cycle">
    <Transition name="spin" mode="out-in">
      <UiIcon :key="meta.icon" :name="meta.icon" :size="18" />
    </Transition>
    <span class="visually-hidden">{{ meta.label }}. Change theme</span>
  </button>
</template>

<style scoped>
.theme-toggle {
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: transparent;
  color: var(--ink);
  transition: background-color var(--dur) var(--ease-out);
}
.theme-toggle:hover {
  background: var(--surface);
}
.spin-enter-active,
.spin-leave-active {
  transition:
    transform 220ms var(--ease-out),
    opacity 220ms var(--ease-out);
}
.spin-enter-from {
  transform: rotate(-90deg) scale(0.6);
  opacity: 0;
}
.spin-leave-to {
  transform: rotate(90deg) scale(0.6);
  opacity: 0;
}
</style>
