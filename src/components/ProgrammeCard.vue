<script setup lang="ts">
import { computed } from 'vue'
import { useFaculties } from '@/data/faculties'
import { useDuration } from '@/data/programmes'
import { useI18n } from '@/i18n'
import type { Programme } from '@/content/types'
import FacultyArt from './ui/FacultyArt.vue'
import UiIcon from './ui/UiIcon.vue'

const props = withDefaults(defineProps<{ programme: Programme; layout?: 'card' | 'row' }>(), { layout: 'card' })

const { m } = useI18n()
const faculties = useFaculties()
const duration = useDuration()
const faculty = computed(() => faculties.get(props.programme.faculty))
const facts = computed(() => {
  const p = props.programme
  return [duration(p), p.ects ? `${p.ects} ECTS` : null, p.languages.join(' / ') || null].filter(Boolean) as string[]
})
const seed = computed(() => [...props.programme.slug].reduce((n, c) => n + c.charCodeAt(0), 0))
</script>

<template>
  <article class="programme" :class="`programme--${layout}`" :style="{ '--fac': faculty?.color ?? 'var(--lake)' }">
    <div class="media">
      <img v-if="programme.image" :src="programme.image" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
      <FacultyArt v-else :variant="faculty?.art ?? 'grid'" :color="faculty?.color ?? 'var(--lake)'" :seed="seed" :animated="false" />
      <span class="level">{{ m.levels[programme.level] }}</span>
    </div>
    <div class="body">
      <p v-if="faculty" class="faculty"><span class="dot" />{{ faculty.short }}</p>
      <h3 class="title">
        <RouterLink :to="programme.path" class="stretched">{{ programme.title }}</RouterLink>
      </h3>
      <p class="summary">{{ programme.summary }}</p>
      <ul v-if="facts.length" class="facts" role="list">
        <li v-for="f in facts" :key="f">{{ f }}</li>
        <li v-if="programme.translated" class="it">{{ m.programme.translated }}</li>
      </ul>
    </div>
    <span class="go" aria-hidden="true"><UiIcon name="arrow-up-right" :size="18" /></span>
  </article>
</template>

<style scoped>
.programme {
  position: relative;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: var(--surface);
  transition:
    transform var(--dur) var(--ease-out),
    box-shadow var(--dur) var(--ease-out),
    border-color var(--dur) var(--ease-out);
}
.programme:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow);
  border-color: var(--line-strong);
}
.programme:focus-within {
  outline: 2px solid var(--signal);
  outline-offset: 2px;
}
.media {
  position: relative;
  aspect-ratio: 16 / 9;
  overflow: hidden;
  background: var(--paper-2);
}
.media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 800ms var(--ease-out);
}
.programme:hover .media img {
  transform: scale(1.05);
}
.media::after {
  content: '';
  position: absolute;
  inset: auto 0 0;
  height: 3px;
  background: var(--fac);
}
.level {
  position: absolute;
  top: 0.8rem;
  left: 0.8rem;
  padding: 0.25em 0.7em;
  border-radius: 999px;
  background: rgb(10 15 21 / 0.6);
  backdrop-filter: blur(8px);
  color: #fff;
  font-size: 0.72rem;
  font-weight: 600;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}
.body {
  display: flex;
  flex-direction: column;
  flex: 1;
  gap: 0.6rem;
  padding: 1.2rem 1.3rem 1.3rem;
}
.faculty {
  display: inline-flex;
  align-items: center;
  gap: 0.45em;
  font-size: 0.78rem;
  font-weight: 600;
  color: var(--ink-2);
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--fac);
}
.title {
  font-size: var(--step-2);
  padding-right: 2rem;
}
.stretched {
  text-decoration: none;
}
.stretched:focus-visible {
  outline: none;
}
.stretched::before {
  content: '';
  position: absolute;
  inset: 0;
}
.summary {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
  color: var(--ink-2);
  font-size: 0.92rem;
}
.facts {
  display: flex;
  flex-wrap: wrap;
  gap: 0.4rem;
  margin-top: auto;
  padding-top: 0.4rem;
}
.facts li {
  padding: 0.2em 0.65em;
  border-radius: 999px;
  background: var(--paper-2);
  font-size: 0.76rem;
  font-weight: 500;
  color: var(--ink-2);
}
.facts .it {
  background: var(--signal-soft);
}
.go {
  position: absolute;
  top: 0.75rem;
  right: 0.75rem;
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--surface);
  transition:
    background-color var(--dur) var(--ease-out),
    color var(--dur) var(--ease-out),
    transform var(--dur) var(--ease-out);
}
.programme:hover .go {
  background: var(--signal);
  color: var(--signal-ink);
  transform: rotate(45deg);
}

/* Row layout (list view) */
@media (min-width: 760px) {
  .programme--row {
    flex-direction: row;
  }
  .programme--row .media {
    flex: 0 0 240px;
    aspect-ratio: auto;
  }
  .programme--row .media::after {
    inset: 0 0 0 auto;
    width: 3px;
    height: auto;
  }
  .programme--row .go {
    top: 50%;
    margin-top: -18px;
    right: 1.25rem;
  }
  .programme--row .body {
    padding-right: 4.5rem;
  }
}
</style>
