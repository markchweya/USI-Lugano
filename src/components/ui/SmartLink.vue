<script setup lang="ts">
import { computed } from 'vue'
import { resolveHref } from '@/content/api'

/** Routes internally when we host the page, otherwise links out to usi.ch (or elsewhere). */
const props = defineProps<{ href: string }>()
const target = computed(() => resolveHref(props.href))
</script>

<template>
  <RouterLink v-if="target.internal" :to="target.href"><slot /></RouterLink>
  <a v-else :href="target.href" target="_blank" rel="noopener"><slot /></a>
</template>
