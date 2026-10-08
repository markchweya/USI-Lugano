import { createRouter, createWebHistory } from 'vue-router'
import { formatTitle } from '@/composables/usePageTitle'
import HomeView from '@/views/HomeView.vue'

export const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/', name: 'home', component: HomeView },
    { path: '/study', name: 'study', component: () => import('@/views/StudyView.vue'), meta: { title: 'Find a programme' } },
    { path: '/explore', name: 'explore', component: () => import('@/views/ExploreView.vue'), meta: { title: 'Explore' } },
    // Every real page from usi.ch keeps its original path, so links and bookmarks map 1:1.
    { path: '/:lang(en|it)/:rest(.*)*', name: 'page', component: () => import('@/views/ContentPageView.vue') },
    { path: '/:pathMatch(.*)*', name: 'not-found', component: () => import('@/views/NotFoundView.vue'), meta: { title: 'Page not found' } },
  ],
  scrollBehavior(to, from, saved) {
    if (saved) return saved
    if (to.hash) return { el: to.hash, top: 96, behavior: 'smooth' }
    if (to.path === from.path) return false // filter changes on the same page keep their scroll position
    return { top: 0 }
  },
})

router.afterEach((to) => {
  if (to.meta.title !== undefined || to.name === 'home') document.title = formatTitle(to.meta.title)
})
