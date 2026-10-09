# Programmes for one language, with the finder's filtering and ordering rules.
define ['backbone', 'underscore', 'lib/search'], (Backbone, _, search) ->
  LEVEL_ORDER = { bachelor: 0, master: 1, phd: 2, executive: 3 }

  Backbone.Collection.extend
    comparator: (a, b) ->
      (LEVEL_ORDER[a.get 'level'] - LEVEL_ORDER[b.get 'level']) or a.get('title').localeCompare(b.get('title'))

    filtered: (state) ->
      { q, level, faculty, taught } = state.attributes
      terms = search.tokens q
      @filter (p) ->
        return false if level and p.get('level') isnt level
        return false if faculty and p.get('faculty') isnt faculty
        return false if taught and taught not in (p.get('languages') or [])
        return true unless terms.length
        hay = search.normalise "#{p.get 'fullTitle'} #{p.get 'title'} #{p.get 'summary'}"
        _.every terms, (t) -> hay.indexOf(t) >= 0
  ,
    # One listing per programme path (the source lists a few twice).
    forLang: (all, lang) ->
      new this _.uniq(_.filter(all, (p) -> p.lang is lang), false, (p) -> p.path)
