import { onBeforeUnmount, watch, type Ref } from 'vue'

let locks = 0

/** Locks page scroll while `active` is true; reference-counted for nested overlays. */
export function useScrollLock(active: Ref<boolean>) {
  let held = false
  const set = (on: boolean) => {
    if (on === held) return
    held = on
    locks += on ? 1 : -1
    const sbw = window.innerWidth - document.documentElement.clientWidth
    document.documentElement.style.overflow = locks > 0 ? 'hidden' : ''
    document.documentElement.style.paddingRight = locks > 0 && sbw > 0 ? `${sbw}px` : ''
  }
  watch(active, set, { immediate: true })
  onBeforeUnmount(() => set(false))
}
