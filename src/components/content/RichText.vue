<script setup lang="ts">
import { useRouter } from 'vue-router'
import { resolveHref } from '@/content/api'

/**
 * Renders sanitised HTML produced by the extractor (tags and href schemes are
 * allow-listed at build time). Clicks on links to pages we host are routed
 * client-side; everything else opens on usi.ch.
 */
defineProps<{ html: string }>()
const router = useRouter()

function onClick(e: MouseEvent) {
  if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return
  const a = (e.target as HTMLElement).closest('a')
  const href = a?.getAttribute('href')
  if (!a || !href) return
  const { internal, href: resolved } = resolveHref(href)
  e.preventDefault()
  if (internal) router.push(resolved)
  else window.open(resolved, '_blank', 'noopener')
}
</script>

<template>
  <div class="prose" @click="onClick" v-html="html" />
</template>

<style scoped>
.prose {
  color: var(--ink-2);
  font-size: var(--step-0);
  line-height: 1.7;
  max-width: 72ch;
}
.prose :deep(p + p),
.prose :deep(p + ul),
.prose :deep(ul + p),
.prose :deep(ol + p),
.prose :deep(p + ol) {
  margin-top: 1em;
}
.prose :deep(p) {
  margin: 0;
}
.prose :deep(strong) {
  color: var(--ink);
  font-weight: 600;
}
.prose :deep(a) {
  color: var(--ink);
  text-decoration: underline;
  text-decoration-color: var(--signal);
  text-decoration-thickness: 1.5px;
  transition: color var(--dur) var(--ease-out);
  overflow-wrap: anywhere;
}
.prose :deep(a:hover) {
  color: var(--signal);
}
.prose :deep(ul),
.prose :deep(ol) {
  margin: 0.75em 0;
  padding-left: 1.25em;
}
.prose :deep(li + li) {
  margin-top: 0.4em;
}
.prose :deep(li::marker) {
  color: var(--signal);
}
.prose :deep(h3),
.prose :deep(h4) {
  margin: 1.6em 0 0.5em;
  color: var(--ink);
  font-size: var(--step-1);
}
.prose :deep(blockquote) {
  margin: 1.5em 0;
  padding-left: 1.25em;
  border-left: 3px solid var(--signal);
  font-family: var(--font-display);
  font-size: var(--step-1);
  color: var(--ink);
}
.prose :deep(table) {
  display: block;
  overflow-x: auto;
  width: 100%;
  margin: 1.25em 0;
  border-collapse: collapse;
  font-size: 0.9rem;
}
.prose :deep(th),
.prose :deep(td) {
  padding: 0.6em 0.8em;
  border-bottom: 1px solid var(--line);
  text-align: left;
  vertical-align: top;
}
.prose :deep(th) {
  color: var(--ink);
  font-weight: 600;
}
</style>
