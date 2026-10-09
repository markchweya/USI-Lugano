import { shallowRef } from 'vue'
import type { Locale } from '@/i18n'

/**
 * Language alternates of the page being viewed, published by content pages
 * and read by the language switcher. Empty on app pages (home, finder…),
 * where the switcher maps localised slugs instead.
 */
export const alternates = shallowRef<Partial<Record<Locale, string>>>({})

export function setAlternates(value: Partial<Record<Locale, string>>) {
  alternates.value = value
}
