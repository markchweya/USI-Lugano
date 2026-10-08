import { ref } from 'vue'

const isOpen = ref(false)
let returnFocus: HTMLElement | null = null

/** Global open/close state for the ⌘K search palette. */
export function useCommandPalette() {
  function open() {
    returnFocus = document.activeElement as HTMLElement | null
    isOpen.value = true
  }

  function close() {
    isOpen.value = false
    // Restore focus to whatever opened the palette, per the dialog pattern.
    requestAnimationFrame(() => returnFocus?.focus?.())
  }

  return { isOpen, open, close }
}
