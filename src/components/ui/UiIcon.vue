<script setup lang="ts">
const paths = {
  search: '<circle cx="11" cy="11" r="7.5"/><path d="m20.5 20.5-4.2-4.2"/>',
  'arrow-right': '<path d="M5 12h14"/><path d="m12.5 5.5 6.5 6.5-6.5 6.5"/>',
  'arrow-left': '<path d="M19 12H5"/><path d="M11.5 5.5 5 12l6.5 6.5"/>',
  'arrow-up-right': '<path d="M7 17 17 7"/><path d="M8 7h9v9"/>',
  sun: '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
  moon: '<path d="M20.5 14.5A8.5 8.5 0 0 1 9.5 3.5a8.5 8.5 0 1 0 11 11Z"/>',
  monitor: '<rect x="2.5" y="3.5" width="19" height="13" rx="2"/><path d="M8 20.5h8M12 16.5v4"/>',
  menu: '<path d="M4 7h16M4 12h16M4 17h10"/>',
  close: '<path d="M18 6 6 18M6 6l12 12"/>',
  'chevron-down': '<path d="m6 9 6 6 6-6"/>',
  'map-pin': '<path d="M19.5 10c0 5.5-7.5 11.5-7.5 11.5S4.5 15.5 4.5 10a7.5 7.5 0 0 1 15 0Z"/><circle cx="12" cy="10" r="2.5"/>',
  calendar: '<rect x="3.5" y="4.5" width="17" height="16" rx="2"/><path d="M16 2.5v4M8 2.5v4M3.5 10h17"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/>',
  filter: '<path d="M4 6h16M7 12h10M10 18h4"/>',
  grid: '<rect x="3.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.5"/>',
  list: '<path d="M9 6h11M9 12h11M9 18h11"/><circle cx="4.5" cy="6" r=".8"/><circle cx="4.5" cy="12" r=".8"/><circle cx="4.5" cy="18" r=".8"/>',
  check: '<path d="M20 6 9 17l-5-5"/>',
  enter: '<path d="M9 10 4 15l5 5"/><path d="M20 4v7a4 4 0 0 1-4 4H4"/>',
  book: '<path d="M2.5 4h6a3.5 3.5 0 0 1 3.5 3.5V21a2.5 2.5 0 0 0-2.5-2.5h-7Z"/><path d="M21.5 4h-6A3.5 3.5 0 0 0 12 7.5V21a2.5 2.5 0 0 1 2.5-2.5h7Z"/>',
  flask: '<path d="M9.5 3h5M10 3v6.5L4.8 18.3A1.8 1.8 0 0 0 6.4 21h11.2a1.8 1.8 0 0 0 1.6-2.7L14 9.5V3"/><path d="M7.5 14.5h9"/>',
  building: '<rect x="4.5" y="2.5" width="15" height="19" rx="1.5"/><path d="M9.5 21.5v-4h5v4M9 7h.01M15 7h.01M12 7h.01M9 11h.01M12 11h.01M15 11h.01M9 15h.01M12 15h.01M15 15h.01"/>',
  cap: '<path d="M22 9.5 12 4.5 2 9.5l10 5 10-5Z"/><path d="M6 11.5v5c3.5 3 8.5 3 12 0v-5M22 9.5v6"/>',
  sparkle: '<path d="M12 3.5 13.8 10 20.5 12l-6.7 2L12 20.5 10.2 14 3.5 12l6.7-2L12 3.5Z"/>',
  language: '<path d="M4 5h9M8.5 3v2M6 5c.5 3 2.5 6 6 8M11 5c-.8 3.5-3.3 6.8-7 8.5"/><path d="m12 21 4.5-10 4.5 10M13.5 17.5h6"/>',
} as const

export type IconName = keyof typeof paths

const props = withDefaults(defineProps<{ name: IconName; size?: number | string; label?: string }>(), {
  size: 20,
})
</script>

<template>
  <svg
    class="icon"
    :width="props.size"
    :height="props.size"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.6"
    stroke-linecap="round"
    stroke-linejoin="round"
    :role="props.label ? 'img' : undefined"
    :aria-label="props.label"
    :aria-hidden="props.label ? undefined : 'true'"
    focusable="false"
    v-html="paths[props.name]"
  />
</template>

<style scoped>
.icon {
  flex: none;
}
</style>
