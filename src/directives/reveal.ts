import type { Directive } from 'vue'

/**
 * v-reveal — fades an element in when it first scrolls into view.
 * Optional value is a delay in ms, for staggering siblings: v-reveal="i * 80".
 * Content stays visible without JS or IntersectionObserver.
 */
let observer: IntersectionObserver | null = null

function getObserver(): IntersectionObserver | null {
  if (typeof IntersectionObserver === 'undefined') return null
  observer ??= new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue
        ;(entry.target as HTMLElement).dataset.reveal = 'in'
        observer?.unobserve(entry.target)
      }
    },
    { rootMargin: '0px 0px -8% 0px', threshold: 0.08 },
  )
  return observer
}

export const reveal: Directive<HTMLElement, number | undefined> = {
  mounted(el, binding) {
    const io = getObserver()
    if (!io) return
    if (binding.value) el.style.setProperty('--reveal-delay', `${binding.value}ms`)
    el.dataset.reveal = ''
    io.observe(el)
  },
  unmounted(el) {
    observer?.unobserve(el)
  },
}
