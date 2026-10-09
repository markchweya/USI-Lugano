import { describe, expect, it } from 'vitest'
// @ts-expect-error — plain ESM build script without type declarations
import { normalize } from './normalize.mjs'

describe('German terminology normalisation', () => {
  it('unifies the student body name', () => {
    expect(normalize('Über die Studierendenkorporation')).toBe('Über die Studierendenschaft')
  })

  it('translates office names with the right case', () => {
    expect(normalize('Leiterin des Research Service')).toBe('Leiterin des Forschungsdienstes')
    expect(normalize('Wenden Sie sich an den Research Service.')).toBe('Wenden Sie sich an den Forschungsdienst.')
    expect(normalize('Der International Relations and Study Abroad Service hilft.')).toBe('Der Dienst für Internationale Beziehungen und Auslandstudium hilft.')
  })

  it('switches feminine Dienststelle to masculine Dienst with matching articles', () => {
    expect(normalize('In Zusammenarbeit mit der Dienststelle für Chancengleichheit')).toBe('In Zusammenarbeit mit dem Dienst für Chancengleichheit')
    expect(normalize('Die Dienststelle Qualitätssicherung und Nachhaltigkeit der USI')).toBe('Der Dienst für Qualitätssicherung und Nachhaltigkeit der USI')
  })

  it('maps the Gleichstellungsdienst variant, genitive included', () => {
    expect(normalize('Kontakt des Gleichstellungsdienstes')).toBe('Kontakt des Dienstes für Chancengleichheit')
  })

  it('uses German names for generic public employers and places', () => {
    expect(normalize('Collaboratore, Amministrazione federale, Berna')).toBe('Collaboratore, Bundesverwaltung, Bern')
  })

  it('keeps names German speakers use in English', () => {
    expect(normalize('Der Career Service und der Alumni Service')).toBe('Der Career Service und der Alumni Service')
  })

  it('never touches markup or links', () => {
    const html = '<a href="/en/research-service">Research Service</a>'
    expect(normalize(html)).toBe('<a href="/en/research-service">Forschungsdienst</a>')
  })

  it('is idempotent', () => {
    const once = normalize('des Research Service und der Dienststelle für Chancengleichheit')
    expect(normalize(once)).toBe(once)
  })
})
