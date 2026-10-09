<script setup lang="ts">
import { useSiteNav } from '@/content/nav'
import stats from '@/data/generated/stats.json'
import { useI18n } from '@/i18n'
import BrandMark from './ui/BrandMark.vue'
import LanguageSwitcher from './ui/LanguageSwitcher.vue'
import UiIcon from './ui/UiIcon.vue'

const { sections, children, count } = useSiteNav()
const { m, n, d, path } = useI18n()
const year = new Date().getFullYear()
</script>

<template>
  <footer class="footer">
    <div class="container">
      <div class="top">
        <div class="intro">
          <BrandMark />
          <p class="motto">{{ m.footer.motto }}</p>
          <address>
            Università della Svizzera italiana<br />
            {{ m.footer.address }}
          </address>
          <RouterLink :to="path('explore')" class="btn btn--ghost btn--sm">{{ m.footer.exploreAll(n(count || stats.pages)) }} <UiIcon name="arrow-right" :size="16" /></RouterLink>
          <LanguageSwitcher variant="inline" class="langs" />
        </div>
        <nav class="cols" :aria-label="m.footer.label">
          <div v-for="s in sections" :key="s.key">
            <p class="col-title">{{ s.label }}</p>
            <ul role="list">
              <li v-for="c in (children[s.key] ?? []).slice(0, 7)" :key="c.path">
                <RouterLink :to="c.path">{{ c.title }}</RouterLink>
              </li>
            </ul>
          </div>
        </nav>
      </div>

      <p class="wordmark" aria-hidden="true">Lugano<span>·</span>Mendrisio<span>·</span>Bellinzona</p>

      <div class="bottom">
        <p>
          {{ m.footer.rights(year) }} {{ m.footer.sourced }} <a href="https://www.usi.ch" target="_blank" rel="noopener">usi.ch</a>,
          {{ m.footer.synced(d(stats.generatedAt)) }}.
        </p>
        <p>
          <a href="https://www.usi.ch/en/privacy" target="_blank" rel="noopener">{{ m.footer.privacy }}</a>
          <span aria-hidden="true">·</span>
          <RouterLink :to="path('explore')">{{ m.footer.sitemap }}</RouterLink>
        </p>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.footer {
  margin-top: var(--section);
  padding-top: clamp(3rem, 6vw, 5rem);
  --ink: #ede8df;
  --ink-2: #b9c0c8;
  --ink-3: #87909a;
  --paper: #0a0f15;
  --line: rgb(237 232 223 / 0.12);
  --line-strong: rgb(237 232 223 / 0.25);
  --surface: #17212c;
  background-color: #070b10;
  color: var(--ink);
  border-top: 1px solid var(--line);
}
.top {
  display: grid;
  gap: 3rem;
}
@media (min-width: 960px) {
  .top {
    grid-template-columns: 1fr 2.2fr;
  }
}
.intro {
  display: grid;
  gap: 1.25rem;
  justify-items: start;
  align-content: start;
}
.langs {
  margin-top: 0.5rem;
}
.langs :deep(.inline-link) {
  color: var(--ink-2);
}
.motto {
  font-family: var(--font-display);
  font-size: var(--step-2);
  font-style: italic;
  line-height: 1.2;
}
address {
  font-style: normal;
  color: var(--ink-3);
  font-size: 0.9rem;
}
.cols {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 2rem;
}
.col-title {
  margin-bottom: 0.9rem;
  font-family: var(--font-mono);
  font-size: 0.72rem;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--ink-3);
}
.cols ul {
  display: grid;
  gap: 0.55rem;
}
.cols a {
  color: var(--ink-2);
  text-decoration: none;
  font-size: 0.92rem;
  transition: color var(--dur);
}
.cols a:hover {
  color: #ff6a45;
}
.wordmark {
  margin: clamp(3rem, 8vw, 6rem) 0 0;
  overflow: hidden;
  font-family: var(--font-display);
  font-size: clamp(2.5rem, 9vw, 9rem);
  line-height: 0.9;
  letter-spacing: -0.04em;
  white-space: nowrap;
  color: transparent;
  -webkit-text-stroke: 1px var(--line-strong);
}
.wordmark span {
  color: #ff6a45;
  -webkit-text-stroke: 0;
  padding-inline: 0.1em;
}
.bottom {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 1rem;
  padding-block: 1.5rem 2rem;
  border-top: 1px solid var(--line);
  font-size: 0.82rem;
  color: var(--ink-3);
}
.bottom a {
  color: var(--ink-2);
}
.bottom p:last-child {
  display: flex;
  gap: 0.5rem;
}
</style>
