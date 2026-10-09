import { watchEffect, type MaybeRefOrGetter, toValue } from 'vue'

const SUFFIX = 'USI — Università della Svizzera italiana'

export function formatTitle(title?: string): string {
  return title ? `${title} · ${SUFFIX}` : SUFFIX
}

/** Keeps document.title in sync for views whose title depends on data. */
export function usePageTitle(title: MaybeRefOrGetter<string | undefined>) {
  watchEffect(() => {
    document.title = formatTitle(toValue(title))
  })
}
