<script setup lang="ts">
defineProps<{ eyebrow?: string; title: string; lede?: string; id?: string }>()
</script>

<template>
  <header class="section-heading">
    <div>
      <p v-if="eyebrow" class="eyebrow">{{ eyebrow }}</p>
      <h2 :id="id" class="title"><slot name="title">{{ title }}</slot></h2>
    </div>
    <div class="aside">
      <p v-if="lede" class="lede">{{ lede }}</p>
      <slot name="actions" />
    </div>
  </header>
</template>

<style scoped>
.section-heading {
  display: grid;
  gap: 1.5rem 4rem;
  align-items: end;
  margin-bottom: clamp(2rem, 4vw, 3.5rem);
}
@media (min-width: 900px) {
  .section-heading {
    grid-template-columns: 1.3fr 1fr;
  }
}
.title {
  margin-top: 0.9rem;
  font-size: var(--step-4);
}
.aside {
  display: grid;
  gap: 1.25rem;
  justify-items: start;
}
.lede {
  max-width: 46ch;
  color: var(--ink-2);
  font-size: var(--step-1);
  line-height: 1.5;
}
</style>
