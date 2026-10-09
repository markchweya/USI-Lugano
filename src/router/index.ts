import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { formatTitle } from '@/composables/usePageTitle'
import { appPath, appSlugs, detectLocale, localeFromPath, locales, messages, setLocale, storedLocale, type AppPage } from '@/i18n'
import HomeView from '@/views/HomeView.vue'

const StudyView = () => import('@/views/StudyView.vue')
const ExploreView = () => import('@/views/ExploreView.vue')

declare module 'vue-router' {
  interface RouteMeta {
    page?: AppPage
  }
}

/** One home / study / explore route per locale, each with its own localised slug. */
const appRoutes: RouteRecordRaw[] = locales.flatMap((l) => [
  { path: `/${l}`, name: `home-${l}`, component: HomeView, meta: { page: 'home' } },
  { path: `/${l}/${appSlugs.study[l]}`, name: `study-${l}`, component: StudyView, meta: { page: 'study' } },
  { path: `/${l}/${appSlugs.explore[l]}`, name: `explore-${l}`, component: ExploreView, meta: { page: 'explore' } },
])

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', redirect: () => `/${storedLocale() ?? detectLocale()}` },
    // Pre-i18n URLs keep working.
    { path: '/study', redirect: (to) => ({ path: appPath('study', 'en'), query: to.query }) },
    { path: '/explore', redirect: (to) => ({ path: appPath('explore', 'en'), query: to.query }) },
    ...appRoutes,
    // Every real page keeps its usi.ch path; German mirrors the English paths under /de.
    { path: '/:locale(en|it|de)/:rest(.*)+', name: 'page', component: () => import('@/views/ContentPageView.vue') },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('@/views/NotFoundView.vue') },
  ],
  scrollBehavior(to, from, saved) {
    if (saved) return saved
    if (to.hash) return { el: to.hash, top: 96, behavior: 'smooth' }
    if (to.path === from.path) return false // filter changes on the same page keep their scroll position
    return { top: 0 }
  },
})

router.beforeEach((to) => {
  const l = localeFromPath(to.path)
  if (l) setLocale(l)
})

router.afterEach((to) => {
  const m = messages[localeFromPath(to.path) ?? 'en']
  if (to.meta.page === 'home') document.title = formatTitle()
  else if (to.meta.page === 'study') document.title = formatTitle(m.study.title)
  else if (to.meta.page === 'explore') document.title = formatTitle(m.explore.title)
  else if (to.name === 'not-found') document.title = formatTitle(m.notFound.title)
})
