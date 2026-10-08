import { computed, ref, watchEffect } from 'vue'

export type ThemePreference = 'light' | 'dark' | 'system'

const STORAGE_KEY = 'usi-theme'
const media = typeof window !== 'undefined' ? window.matchMedia('(prefers-color-scheme: dark)') : null

function readPreference(): ThemePreference {
  try {
    const v = localStorage.getItem(STORAGE_KEY)
    if (v === 'light' || v === 'dark' || v === 'system') return v
  } catch {
    /* storage unavailable (private mode, blocked cookies) */
  }
  return 'system'
}

// Module-level state: one source of truth shared by every component.
const preference = ref<ThemePreference>(readPreference())
const systemDark = ref(media?.matches ?? false)
media?.addEventListener('change', (e) => (systemDark.value = e.matches))

const resolved = computed<'light' | 'dark'>(() =>
  preference.value === 'system' ? (systemDark.value ? 'dark' : 'light') : preference.value,
)

let started = false

export function useTheme() {
  if (!started && typeof document !== 'undefined') {
    started = true
    watchEffect(() => {
      document.documentElement.dataset.theme = resolved.value
      try {
        localStorage.setItem(STORAGE_KEY, preference.value)
      } catch {
        /* ignore */
      }
    })
  }

  const order: ThemePreference[] = ['system', 'light', 'dark']
  function cycle() {
    preference.value = order[(order.indexOf(preference.value) + 1) % order.length]!
  }

  return { preference, resolved, cycle }
}
