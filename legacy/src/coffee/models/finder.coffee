# Programme finder state. Lives in the URL: the model is parsed from and
# serialised to the query string, so every selection is shareable.
define ['backbone', 'underscore'], (Backbone, _) ->
  LEVELS = ['bachelor', 'master']
  LANGS = ['EN', 'IT']

  Backbone.Model.extend
    defaults: { q: '', level: '', faculty: '', taught: '' }

    # Unknown values are dropped rather than producing an empty, confusing result.
    fromQuery: (query, faculties) ->
      @set
        q: (query.q ? '').slice(0, 80)
        level: if query.level in LEVELS then query.level else ''
        faculty: if query.faculty in faculties then query.faculty else ''
        taught: if query.taught in LANGS then query.taught else ''
      this

    toQuery: -> _.pick @attributes, (v) -> v

    isEmpty: -> _.isEmpty @toQuery()
