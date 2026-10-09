/**
 * Key figures as published on usi.ch → University → Portrait
 * (/en/university/who-we-are/at-a-glance). Update when USI publishes new numbers.
 */
export const keyFacts = [
  { value: 4749, key: 'students' },
  { value: 1591, key: 'staff' },
  { value: 115, key: 'countries' },
  { value: 1996, key: 'founded', plain: true },
] as const

export const portraitPath = {
  en: '/en/university/who-we-are/at-a-glance',
  it: '/it/universita/chi-siamo/in-uno-sguardo',
  de: '/de/university/who-we-are/at-a-glance',
} as const

export const campusPath = {
  en: '/en/university/where-to-find-us',
  it: '/it/universita/dove-siamo',
  de: '/de/university/where-to-find-us',
} as const
