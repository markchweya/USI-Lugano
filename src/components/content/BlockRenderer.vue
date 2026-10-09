<script setup lang="ts">
import type { Block } from '@/content/types'
import RichText from './RichText.vue'
import YouTubeEmbed from './YouTubeEmbed.vue'
import MediaCarousel from './MediaCarousel.vue'
import SmartLink from '../ui/SmartLink.vue'
import UiIcon from '../ui/UiIcon.vue'
import { slugify } from '@/lib/slugify'

defineProps<{ blocks: Block[] }>()

</script>

<template>
  <div class="blocks">
    <template v-for="(b, i) in blocks" :key="i">
      <component :is="b.level === 2 ? 'h2' : 'h3'" v-if="b.t === 'h'" :id="slugify(b.text)" class="heading" :class="`heading--${b.level}`">
        {{ b.text }}
      </component>

      <RichText v-else-if="b.t === 'html'" :html="b.html" />

      <MediaCarousel v-else-if="b.t === 'gallery'" :items="b.items" />

      <YouTubeEmbed v-else-if="b.t === 'video'" :id="b.youtube" :title="b.caption" />

      <figure v-else-if="b.t === 'image'" class="figure">
        <img :src="b.src" :alt="b.alt" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
      </figure>

      <div v-else-if="b.t === 'accordion'" class="accordion">
        <details v-for="item in b.items" :key="item.title" class="acc-item">
          <summary>
            <span>{{ item.title }}</span>
            <UiIcon name="chevron-down" :size="18" class="acc-icon" />
          </summary>
          <div class="acc-body"><RichText :html="item.html" /></div>
        </details>
      </div>

      <figure v-else-if="b.t === 'quote'" class="quote">
        <img v-if="b.photo" :src="b.photo" alt="" class="quote-photo" loading="lazy" referrerpolicy="no-referrer" />
        <blockquote><RichText :html="b.html" /></blockquote>
        <figcaption>
          <strong>{{ b.name }}</strong>
          <span>{{ b.role }}</span>
        </figcaption>
      </figure>

      <ul v-else-if="b.t === 'cards'" class="cards" role="list">
        <li v-for="c in b.items" :key="c.href" class="card">
          <div class="card-media">
            <img v-if="c.image" :src="c.image" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
          </div>
          <SmartLink :href="c.href" class="card-link">
            <span>{{ c.title }}</span>
            <UiIcon name="arrow-up-right" :size="18" />
          </SmartLink>
        </li>
      </ul>
    </template>
  </div>
</template>

<style scoped>
.blocks {
  display: grid;
  gap: 1.5rem;
  min-width: 0;
}
.heading {
  margin-top: 1.5rem;
  color: var(--ink);
  scroll-margin-top: calc(var(--header-h) + 24px);
}
.heading--2 {
  font-size: var(--step-3);
}
.heading--3 {
  font-size: var(--step-2);
}
.figure {
  margin: 0;
}
.figure img {
  width: 100%;
  border-radius: var(--radius);
}

.accordion {
  border-top: 1px solid var(--line);
}
.acc-item {
  border-bottom: 1px solid var(--line);
}
.acc-item summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1.15rem 0.25rem;
  cursor: pointer;
  list-style: none;
  font-weight: 600;
  font-size: var(--step-1);
  line-height: 1.35;
}
.acc-item summary::-webkit-details-marker {
  display: none;
}
.acc-item summary:hover {
  color: var(--signal);
}
.acc-icon {
  transition: transform var(--dur) var(--ease-out);
}
.acc-item[open] .acc-icon {
  transform: rotate(180deg);
}
.acc-body {
  padding: 0 0.25rem 1.5rem;
}

.quote {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 0.5rem 1.25rem;
  margin: 0;
  padding: clamp(1.25rem, 3vw, 2rem);
  border-radius: var(--radius);
  background: var(--surface);
  border: 1px solid var(--line);
}
.quote-photo {
  grid-row: span 2;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  object-fit: cover;
}
.quote blockquote {
  margin: 0;
}
.quote blockquote :deep(.prose) {
  font-family: var(--font-display);
  font-size: var(--step-1);
  line-height: 1.5;
  color: var(--ink);
}
.quote figcaption {
  display: grid;
  font-size: 0.9rem;
  color: var(--ink-3);
}
.quote figcaption strong {
  color: var(--ink);
}
@media (max-width: 560px) {
  .quote {
    grid-template-columns: 1fr;
  }
  .quote-photo {
    grid-row: auto;
  }
}

.cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(min(100%, 240px), 1fr));
  gap: 1rem;
}
.card {
  position: relative;
  overflow: hidden;
  border-radius: var(--radius);
  background: var(--surface);
  border: 1px solid var(--line);
  transition:
    transform var(--dur) var(--ease-out),
    box-shadow var(--dur) var(--ease-out);
}
.card:hover {
  transform: translateY(-3px);
  box-shadow: var(--shadow);
}
.card-media {
  aspect-ratio: 16 / 10;
  background: linear-gradient(135deg, var(--lake-soft), var(--signal-soft));
}
.card-media img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 700ms var(--ease-out);
}
.card:hover .card-media img {
  transform: scale(1.05);
}
.card-link {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  padding: 1rem 1.1rem;
  font-weight: 600;
  text-decoration: none;
}
.card-link::after {
  content: '';
  position: absolute;
  inset: 0;
}
</style>
