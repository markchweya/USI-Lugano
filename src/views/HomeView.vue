<script setup lang="ts">
import { computed, ref, shallowRef, watch } from 'vue'
import { useRouter } from 'vue-router'
import { findEntry, loadPage } from '@/content/api'
import type { Card, EventTeaser, Level } from '@/content/types'
import { useSiteNav } from '@/content/nav'
import { levelOrder, useProgrammes } from '@/data/programmes'
import { useFaculties } from '@/data/faculties'
import { campusPath, keyFacts, portraitPath } from '@/data/facts'
import events from '@/data/generated/events.json'
import stats from '@/data/generated/stats.json'
import { useCommandPalette } from '@/composables/useCommandPalette'
import { useI18n } from '@/i18n'
import LakeScene from '@/components/home/LakeScene.vue'
import ProgrammeCard from '@/components/ProgrammeCard.vue'
import FacultyArt from '@/components/ui/FacultyArt.vue'
import SectionHeading from '@/components/ui/SectionHeading.vue'
import SmartLink from '@/components/ui/SmartLink.vue'
import CountUp from '@/components/ui/CountUp.vue'
import UiIcon from '@/components/ui/UiIcon.vue'

const router = useRouter()
const palette = useCommandPalette()
const { locale, m, n, path } = useI18n()
const { sections, children, entries } = useSiteNav()
const programmes = useProgrammes()
const facultyNames = useFaculties()

/* Intent builder */
const intentLevel = ref<Level | ''>('')
const intentFaculty = ref('')
const levels = computed(() => levelOrder.filter((l) => programmes.value.some((p) => p.level === l)))
function explore() {
  router.push({
    path: path('study'),
    query: { ...(intentLevel.value && { level: intentLevel.value }), ...(intentFaculty.value && { faculty: intentFaculty.value }) },
  })
}

/* Programmes rail — those with real photography first */
const featured = computed(() => [...programmes.value].sort((a, b) => Number(!!b.image) - Number(!!a.image)).slice(0, 10))
const rail = ref<HTMLElement>()
const scrollRail = (dir: 1 | -1) => rail.value?.scrollBy({ left: dir * Math.min(rail.value.clientWidth * 0.8, 720), behavior: 'smooth' })

const facultyCards = computed(() =>
  facultyNames.list().map((f) => ({ ...f, count: programmes.value.filter((p) => p.faculty === f.slug).length })),
)

/* Campuses come straight from the real "Where we are" page, in the current language */
const campuses = shallowRef<Card[]>([])
watch(
  locale,
  async (l) => {
    try {
      const entry = (await findEntry(campusPath[l])) ?? (await findEntry(campusPath.en))
      if (!entry) return
      const page = await loadPage(entry.id)
      const block = page.blocks.find((b) => b.t === 'cards')
      campuses.value = block?.t === 'cards' ? block.items : []
    } catch {
      /* section simply stays hidden */
    }
  },
  { immediate: true },
)

/* Event titles stay in their original language; German shows the English listing. */
const teasers = computed(() => {
  const want = locale.value === 'it' ? 'it' : 'en'
  const list = (events as EventTeaser[]).filter((e) => e.lang === want)
  return (list.length ? list : (events as EventTeaser[]).filter((e) => e.lang === 'en')).slice(0, 6)
})

const pageCount = computed(() => n(entries.value.length || stats.pages))
const kWords = computed(() => n(Math.round(entries.value.reduce((s, e) => s + e.words, 0) / 1000) || Math.round(stats.words / 1000)))
</script>

<template>
  <div class="home">
    <!-- Hero -->
    <section class="hero container">
      <div class="hero-copy">
        <p class="eyebrow">{{ m.home.eyebrow }}</p>
        <h1 class="hero-title" :class="{ 'hero-title--long': (m.home.mottoA + m.home.mottoB).length > 32 }">
          {{ m.home.mottoA }}<br />
          <span class="serif-accent">{{ m.home.mottoB }}</span>
        </h1>
        <p class="hero-lede">{{ m.home.lede }}</p>

        <form class="intent" @submit.prevent="explore">
          <label class="intent-part">
            <span class="intent-k">{{ m.home.intentStudy }}</span>
            <select v-model="intentLevel" :aria-label="m.home.intentLevelLabel">
              <option value="">{{ m.home.anyLevel }}</option>
              <option v-for="l in levels" :key="l" :value="l">{{ m.home.levelOption(m.levels[l]) }}</option>
            </select>
          </label>
          <label class="intent-part">
            <span class="intent-k">{{ m.home.intentIn }}</span>
            <select v-model="intentFaculty" :aria-label="m.home.intentFieldLabel">
              <option value="">{{ m.home.anyField }}</option>
              <option v-for="f in facultyCards" :key="f.slug" :value="f.slug">{{ f.short }}</option>
            </select>
          </label>
          <button type="submit" class="btn btn--signal">{{ m.home.showProgrammes }} <UiIcon name="arrow-right" :size="16" /></button>
        </form>

        <button type="button" class="hero-search" @click="palette.open()">
          <UiIcon name="search" :size="16" />
          {{ m.home.searchHint(pageCount) }}
          <kbd>/</kbd>
        </button>
      </div>
      <div class="hero-art">
        <LakeScene />
      </div>
    </section>

    <!-- Key facts -->
    <section class="container facts" :aria-label="m.home.factsLabel">
      <dl>
        <div v-for="(f, i) in keyFacts" :key="f.key" v-reveal="i * 90" class="fact">
          <dt>{{ m.home.facts[f.key] }}</dt>
          <dd><CountUp :value="f.value" :plain="'plain' in f" /></dd>
        </div>
      </dl>
      <RouterLink :to="portraitPath[locale]" class="facts-src">{{ m.home.factsSource }} <UiIcon name="arrow-right" :size="14" /></RouterLink>
    </section>

    <!-- Programmes -->
    <section class="section">
      <div class="container">
        <SectionHeading :eyebrow="m.home.study.eyebrow" :title="m.home.study.title" :lede="m.home.study.lede(programmes.length)">
          <template #actions>
            <div class="rail-actions">
              <RouterLink :to="path('study')" class="btn btn--ghost">{{ m.home.study.all }} <UiIcon name="arrow-right" :size="16" /></RouterLink>
              <button type="button" class="rail-btn" @click="scrollRail(-1)"><UiIcon name="arrow-left" :label="m.home.study.scrollLeft" /></button>
              <button type="button" class="rail-btn" @click="scrollRail(1)"><UiIcon name="arrow-right" :label="m.home.study.scrollRight" /></button>
            </div>
          </template>
        </SectionHeading>
      </div>
      <div ref="rail" class="rail" tabindex="0" :aria-label="m.home.study.rail">
        <div v-for="p in featured" :key="p.id" class="rail-item">
          <ProgrammeCard :programme="p" />
        </div>
      </div>
    </section>

    <!-- Faculties -->
    <section class="section faculties">
      <div class="container">
        <SectionHeading :eyebrow="m.home.faculties.eyebrow" :title="m.home.faculties.title" :lede="m.home.faculties.lede" />
        <ul class="bento" role="list">
          <li v-for="(f, i) in facultyCards" :key="f.slug" v-reveal="i * 70" class="bento-item" :style="{ '--fac': f.color }">
            <FacultyArt :variant="f.art" :color="f.color" :seed="i + 3" class="bento-art" />
            <div class="bento-body">
              <h3 class="bento-title">
                <RouterLink :to="{ path: path('study'), query: { faculty: f.slug } }" class="bento-link">{{ f.name }}</RouterLink>
              </h3>
              <p class="bento-meta">
                <span>{{ f.count ? m.home.faculties.count(f.count) : m.home.faculties.research }}</span>
                <UiIcon name="arrow-up-right" :size="18" />
              </p>
            </div>
          </li>
        </ul>
      </div>
    </section>

    <!-- Campuses -->
    <section v-if="campuses.length" class="section">
      <div class="container">
        <SectionHeading id="campus" :eyebrow="m.home.campus.eyebrow" :title="m.home.campus.title" :lede="m.home.campus.lede">
          <template #actions>
            <RouterLink :to="campusPath[locale]" class="btn btn--ghost">{{ m.home.campus.cta }} <UiIcon name="arrow-right" :size="16" /></RouterLink>
          </template>
        </SectionHeading>
        <ul class="campuses" role="list">
          <li v-for="(c, i) in campuses" :key="c.href" v-reveal="i * 80" class="campus">
            <img v-if="c.image" :src="c.image" alt="" loading="lazy" decoding="async" referrerpolicy="no-referrer" />
            <SmartLink :href="c.href" class="campus-link">
              <span>{{ c.title }}</span>
              <UiIcon name="arrow-up-right" :size="18" />
            </SmartLink>
          </li>
        </ul>
      </div>
    </section>

    <!-- Explore by area -->
    <section class="section areas">
      <div class="container">
        <SectionHeading :eyebrow="m.home.areas.eyebrow" :title="m.home.areas.title" :lede="m.home.areas.lede(pageCount, kWords)">
          <template #actions>
            <RouterLink :to="path('explore')" class="btn btn--ghost">{{ m.home.areas.all }} <UiIcon name="arrow-right" :size="16" /></RouterLink>
          </template>
        </SectionHeading>
        <div class="area-grid">
          <article v-for="(s, i) in sections" :key="s.key" v-reveal="i * 80" class="area">
            <p class="area-n">0{{ i + 1 }}</p>
            <h3 class="area-title">{{ s.label }}</h3>
            <p class="area-blurb">{{ s.blurb }}</p>
            <ul role="list" class="area-links">
              <li v-for="c in (children[s.key] ?? []).slice(0, 5)" :key="c.path">
                <RouterLink :to="c.path">{{ c.title }}</RouterLink>
              </li>
            </ul>
            <RouterLink :to="{ path: path('explore'), query: { section: s.key } }" class="area-all">
              {{ m.home.areas.allIn(s.label) }} <UiIcon name="arrow-right" :size="14" />
            </RouterLink>
          </article>
        </div>
      </div>
    </section>

    <!-- Events -->
    <section v-if="teasers.length" class="section events">
      <div class="container">
        <SectionHeading :eyebrow="m.home.events.eyebrow" :title="m.home.events.title" :lede="m.home.events.lede" />
        <ol class="event-list" role="list">
          <li v-for="(e, i) in teasers" :key="e.href" v-reveal="i * 60" class="event">
            <span class="event-n">{{ String(i + 1).padStart(2, '0') }}</span>
            <div class="event-body">
              <SmartLink :href="e.href" class="event-title">{{ e.title }}</SmartLink>
              <p v-if="e.org" class="event-org">{{ e.org }}</p>
            </div>
            <UiIcon name="arrow-up-right" :size="20" class="event-go" />
          </li>
        </ol>
      </div>
    </section>

    <!-- CTA -->
    <section class="container">
      <div class="cta" v-reveal>
        <div>
          <p class="eyebrow cta-eyebrow">{{ m.home.cta.eyebrow }}</p>
          <h2 class="cta-title">{{ m.home.cta.title }}</h2>
        </div>
        <div class="cta-actions">
          <RouterLink :to="path('study')" class="btn btn--signal">{{ m.home.cta.find }} <UiIcon name="arrow-right" :size="16" /></RouterLink>
          <button type="button" class="btn cta-ghost" @click="palette.open()"><UiIcon name="search" :size="16" /> {{ m.home.cta.search }}</button>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
/* Hero */
.hero {
  display: grid;
  gap: clamp(2rem, 5vw, 4rem);
  align-items: center;
  padding-block: clamp(2rem, 6vw, 5rem) clamp(3rem, 6vw, 5rem);
}
@media (min-width: 1000px) {
  .hero {
    grid-template-columns: 1.1fr 1fr;
  }
}
.hero-title {
  margin-top: 1.25rem;
  font-size: var(--step-5);
  line-height: 0.98;
  letter-spacing: -0.035em;
}
.hero-title--long {
  font-size: clamp(2.6rem, 1.6rem + 3.6vw, 5.4rem);
}
.hero-lede {
  max-width: 52ch;
  margin-top: 1.75rem;
  font-size: var(--step-1);
  line-height: 1.55;
  color: var(--ink-2);
}
.intent {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.5rem 1rem;
  margin-top: 2.25rem;
  padding: 0.6rem 0.6rem 0.6rem 1.25rem;
  border: 1px solid var(--line-strong);
  border-radius: 24px;
  background: var(--surface);
  box-shadow: var(--shadow-sm);
}
.intent-part {
  display: inline-flex;
  align-items: baseline;
  gap: 0.45rem;
}
.intent-k {
  color: var(--ink-3);
  font-size: 0.95rem;
}
.intent select {
  appearance: none;
  padding: 0.2rem 1.4rem 0.2rem 0;
  border: 0;
  border-bottom: 1.5px dashed var(--signal);
  background: transparent
    url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%23e8502e' stroke-width='2.5'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E")
    no-repeat right center;
  font-family: var(--font-display);
  font-size: var(--step-1);
  color: var(--ink);
  cursor: pointer;
}
.intent select option {
  background: var(--surface);
  color: var(--ink);
}
.intent .btn {
  margin-left: auto;
}
.hero-search {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 1rem;
  padding: 0.4rem 0;
  border: 0;
  background: none;
  color: var(--ink-3);
  font-size: 0.9rem;
  text-align: left;
}
.hero-search:hover {
  color: var(--ink);
}
.hero-search kbd {
  padding: 0 0.4em;
  border: 1px solid var(--line-strong);
  border-radius: 4px;
  font-family: var(--font-mono);
  font-size: 0.75rem;
}

/* Facts */
.facts {
  padding-block: 1rem 2rem;
}
.facts dl {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  margin: 0;
  border-top: 1px solid var(--line-strong);
}
@media (min-width: 800px) {
  .facts dl {
    grid-template-columns: repeat(4, 1fr);
  }
}
.fact {
  display: flex;
  flex-direction: column-reverse;
  gap: 0.35rem;
  padding: 1.5rem 1rem 1.5rem 0;
  border-bottom: 1px solid var(--line);
}
.fact dd {
  margin: 0;
  font-family: var(--font-display);
  font-size: var(--step-4);
  line-height: 1;
  letter-spacing: -0.03em;
}
.fact dt {
  color: var(--ink-3);
  font-size: 0.92rem;
}
.facts-src {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  margin-top: 0.9rem;
  font-size: 0.8rem;
  color: var(--ink-3);
  text-decoration: none;
}
.facts-src:hover {
  color: var(--ink);
}

/* Rail */
.rail-actions {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}
.rail-btn {
  display: grid;
  place-items: center;
  width: 46px;
  height: 46px;
  border: 1px solid var(--line-strong);
  border-radius: 50%;
  background: none;
  transition: background-color var(--dur);
}
.rail-btn:hover {
  background: var(--ink);
  color: var(--paper);
}
.rail {
  display: flex;
  gap: 1.25rem;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scroll-padding-inline: max(var(--gutter), calc((100vw - var(--max)) / 2 + var(--gutter)));
  padding: 0.5rem max(var(--gutter), calc((100vw - var(--max)) / 2 + var(--gutter))) 1.5rem;
  scrollbar-width: none;
}
.rail::-webkit-scrollbar {
  display: none;
}
.rail-item {
  flex: 0 0 min(340px, 82vw);
  scroll-snap-align: start;
  display: flex;
}
.rail-item > * {
  flex: 1;
}

/* Faculties bento */
.faculties {
  background: var(--paper-2);
}
.bento {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 280px), 1fr));
  gap: 1rem;
}
@media (min-width: 1000px) {
  .bento {
    grid-template-columns: repeat(6, 1fr);
    grid-auto-rows: 260px;
  }
  .bento-item:nth-child(1) {
    grid-column: span 3;
    grid-row: span 2;
  }
  .bento-item:nth-child(2),
  .bento-item:nth-child(3) {
    grid-column: span 3;
  }
  .bento-item:nth-child(n + 4) {
    grid-column: span 2;
  }
}
.bento-item {
  position: relative;
  display: flex;
  min-height: 240px;
  overflow: hidden;
  border-radius: var(--radius-lg);
  background: var(--surface);
  isolation: isolate;
  transition: transform var(--dur) var(--ease-out);
}
.bento-item:hover {
  transform: translateY(-4px);
}
.bento-item:focus-within {
  outline: 2px solid var(--signal);
  outline-offset: 3px;
}
.bento-art {
  position: absolute;
  inset: 0;
  z-index: -1;
  transition: transform 1.2s var(--ease-out);
}
.bento-item:hover .bento-art {
  transform: scale(1.06);
}
.bento-body {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  gap: 0.6rem;
  width: 100%;
  padding: 1.5rem;
  background: linear-gradient(to top, color-mix(in oklab, var(--surface) 95%, transparent) 30%, transparent);
}
.bento-title {
  font-size: var(--step-2);
  max-width: 18ch;
}
.bento-item:nth-child(1) .bento-title {
  font-size: var(--step-3);
}
.bento-link {
  text-decoration: none;
}
.bento-link:focus-visible {
  outline: none;
}
.bento-link::after {
  content: '';
  position: absolute;
  inset: 0;
}
.bento-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 0.9rem;
  color: var(--ink-2);
}
.bento-meta .icon {
  color: var(--fac);
}

/* Campuses */
.campuses {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 220px), 1fr));
  gap: 1rem;
}
.campus {
  position: relative;
  aspect-ratio: 3 / 4;
  overflow: hidden;
  border-radius: var(--radius-lg);
  background: var(--paper-2);
}
.campus img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 1s var(--ease-out);
}
.campus:hover img {
  transform: scale(1.06);
}
.campus::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(to top, rgb(5 8 12 / 0.75), transparent 55%);
  pointer-events: none;
}
.campus-link {
  position: absolute;
  inset: auto 0 0;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.25rem;
  color: #fff;
  font-family: var(--font-display);
  font-size: var(--step-2);
  line-height: 1.1;
  text-decoration: none;
}
.campus-link::before {
  content: '';
  position: absolute;
  inset: -1000px 0 0;
}

/* Areas */
.area-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 260px), 1fr));
  border-top: 1px solid var(--line-strong);
}
.area {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  padding: 2rem 1.5rem 2rem 0;
}
@media (min-width: 1000px) {
  .area + .area {
    padding-left: 1.5rem;
    border-left: 1px solid var(--line);
  }
}
.area-n {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  color: var(--signal);
}
.area-title {
  font-size: var(--step-3);
}
.area-blurb {
  color: var(--ink-2);
  font-size: 0.92rem;
}
.area-links {
  display: grid;
  gap: 0.4rem;
  margin-top: 0.5rem;
}
.area-links a {
  color: var(--ink);
  font-size: 0.92rem;
  text-decoration: none;
  background: linear-gradient(var(--signal), var(--signal)) no-repeat 0 100% / 0 1.5px;
  transition: background-size var(--dur) var(--ease-out);
}
.area-links a:hover {
  background-size: 100% 1.5px;
}
.area-all {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  margin-top: auto;
  padding-top: 1rem;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--signal);
  text-decoration: none;
}

/* Events */
.event-list {
  border-top: 1px solid var(--line-strong);
}
.event {
  position: relative;
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem 0.5rem;
  border-bottom: 1px solid var(--line);
  transition: background-color var(--dur);
}
.event:hover {
  background: var(--surface);
}
.event-n {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  color: var(--ink-3);
}
.event-title {
  font-family: var(--font-display);
  font-size: var(--step-2);
  line-height: 1.2;
  text-decoration: none;
}
.event-title::after {
  content: '';
  position: absolute;
  inset: 0;
}
.event-org {
  margin-top: 0.35rem;
  color: var(--ink-3);
  font-size: 0.9rem;
}
.event-go {
  color: var(--ink-3);
  transition:
    transform var(--dur) var(--ease-out),
    color var(--dur);
}
.event:hover .event-go {
  color: var(--signal);
  transform: translate(3px, -3px);
}

/* CTA */
.cta {
  display: grid;
  gap: 2rem;
  align-items: end;
  margin-top: var(--section);
  padding: clamp(2rem, 6vw, 4.5rem);
  border-radius: var(--radius-lg);
  background:
    radial-gradient(120% 140% at 100% 0%, color-mix(in oklab, var(--signal) 55%, transparent), transparent 55%),
    radial-gradient(90% 120% at 0% 100%, color-mix(in oklab, var(--lake) 70%, transparent), transparent 60%),
    #0b1520;
  color: #f5f2ec;
}
@media (min-width: 900px) {
  .cta {
    grid-template-columns: 1.4fr 1fr;
  }
}
.cta-eyebrow {
  color: rgb(245 242 236 / 0.7);
}
.cta-title {
  margin-top: 1rem;
  font-size: var(--step-4);
}
.cta-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}
@media (min-width: 900px) {
  .cta-actions {
    justify-content: flex-end;
  }
}
.cta-ghost {
  --btn-bg: rgb(255 255 255 / 0.1);
  --btn-fg: #f5f2ec;
  border-color: rgb(255 255 255 / 0.25);
}
</style>
