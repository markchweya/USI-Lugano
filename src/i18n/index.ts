import { computed, ref } from 'vue'
import en, { type Messages } from './en'
import it from './it'
import de from './de'

export const locales = ['en', 'it', 'de'] as const
export type Locale = (typeof locales)[number]

export const messages: Record<Locale, Messages> = { en, it, de }

/** BCP-47 tags for Intl: Swiss conventions (4’749, 9.10.2026) for IT and DE. */
export const intlTag: Record<Locale, string> = { en: 'en-GB', it: 'it-CH', de: 'de-CH' }

/** Localised slugs for the app's own pages (content pages keep usi.ch's paths). */
export const appSlugs = {
  study: { en: 'study', it: 'programmi', de: 'studiengaenge' },
  explore: { en: 'explore', it: 'esplora', de: 'entdecken' },
} as const satisfies Record<string, Record<Locale, string>>

export type AppPage = 'home' | keyof typeof appSlugs

export function isLocale(value: unknown): value is Locale {
  return typeof value === 'string' && (locales as readonly string[]).includes(value)
}

export function localeFromPath(path: string): Locale | null {
  const seg = path.split('/')[1]
  return isLocale(seg) ? seg : null
}

/** Picks the best locale from the browser's preferences, defaulting to English. */
export function detectLocale(preferred: readonly string[] = typeof navigator !== 'undefined' ? navigator.languages : []): Locale {
  for (const tag of preferred) {
    const base = tag.toLowerCase().split('-')[0]
    if (isLocale(base)) return base
  }
  return 'en'
}

// Module-level state: the router sets it on every navigation.
const current = ref<Locale>('en')

export function setLocale(locale: Locale) {
  current.value = locale
  if (typeof document !== 'undefined') document.documentElement.lang = locale
  try {
    localStorage.setItem('usi-locale', locale)
  } catch {
    /* storage unavailable */
  }
}

export function storedLocale(): Locale | null {
  try {
    const v = localStorage.getItem('usi-locale')
    return isLocale(v) ? v : null
  } catch {
    return null
  }
}

export function appPath(page: AppPage, locale: Locale): string {
  return page === 'home' ? `/${locale}` : `/${locale}/${appSlugs[page][locale]}`
}

/** If `path` is one of the app's own pages, returns which one. */
export function appPageOf(path: string): AppPage | null {
  const [, loc, slug, ...rest] = path.replace(/\/+$/, '').split('/')
  if (!isLocale(loc) || rest.length) return null
  if (slug === undefined || slug === '') return 'home'
  for (const page of Object.keys(appSlugs) as (keyof typeof appSlugs)[]) {
    if (appSlugs[page][loc] === slug) return page
  }
  return null
}

export function useI18n() {
  const m = computed(() => messages[current.value])
  const tag = computed(() => intlTag[current.value])

  /** Locale-aware number, e.g. 4’749 in Swiss locales. */
  const n = (value: number) => new Intl.NumberFormat(tag.value).format(value)
  const d = (value: Date | string, opts: Intl.DateTimeFormatOptions = { day: 'numeric', month: 'long', year: 'numeric' }) =>
    new Intl.DateTimeFormat(tag.value, opts).format(typeof value === 'string' ? new Date(value) : value)

  return {
    locale: computed(() => current.value),
    m,
    n,
    d,
    path: (page: AppPage, locale: Locale = current.value) => appPath(page, locale),
  }
}
