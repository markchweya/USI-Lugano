# Localised slugs for the app's own views, and the hash URLs that address them.
# Content pages keep their usi.ch paths: #/en/education/bachelor/architecture.
define ['underscore'], (_) ->
  VIEWS =
    study: { en: 'study', it: 'programmi', de: 'studiengaenge' }
    explore: { en: 'explore', it: 'esplora', de: 'entdecken' }
    colophon: { en: 'colophon', it: 'colophon', de: 'kolophon' }

  # Section roots, as on usi.ch: Italian has its own paths, German mirrors English.
  SECTIONS =
    education: { en: '/en/education', it: '/it/formazione', de: '/de/education' }
    research: { en: '/en/research', it: '/it/ricerca', de: '/de/research' }
    innovation: { en: '/en/innovation', it: '/it/innovazione', de: '/de/innovation' }
    university: { en: '/en/university', it: '/it/universita', de: '/de/university' }

  sectionKeys = _.keys SECTIONS

  serialise = (query) ->
    pairs = ("#{encodeURIComponent k}=#{encodeURIComponent v}" for k, v of query when v? and v isnt '')
    if pairs.length then '?' + pairs.join('&') else ''

  paths =
    VIEWS: VIEWS
    SECTIONS: SECTIONS
    sectionKeys: sectionKeys

    # '#/it/programmi?level=master'
    view: (name, lang, query = {}) ->
      slug = VIEWS[name]?[lang]
      "#/#{lang}" + (if slug then "/#{slug}" else '') + serialise(query)

    home: (lang) -> "#/#{lang}"
    page: (path) -> "##{path}"

    # 'it/programmi' → { lang: 'it', view: 'study' }; content → { lang, view: 'page', path }
    parse: (fragment = '') ->
      clean = fragment.replace(/^[#\/]+/, '').replace(/\/+$/, '')
      [lang, rest...] = clean.split '/'
      return { lang: null, view: 'root' } unless lang
      return { lang: null, view: 'unknown', path: "/#{clean}" } unless lang in ['en', 'it', 'de']
      return { lang, view: 'home' } unless rest.length
      if rest.length is 1
        for name, slugs of VIEWS when slugs[lang] is rest[0]
          return { lang, view: name }
      { lang, view: 'page', path: "/#{clean}" }

    parseQuery: (qs) ->
      out = {}
      return out unless qs
      for pair in qs.split('&') when pair
        [k, v] = pair.split '='
        try
          out[decodeURIComponent k] = decodeURIComponent((v ? '').replace /\+/g, ' ')
      out

    serialise: serialise

    sectionOf: (path) ->
      _.find(sectionKeys, (key) ->
        _.some _.values(SECTIONS[key]), (root) -> path is root or path.indexOf("#{root}/") is 0
      ) ? 'other'

    langOf: (path) ->
      seg = path.split('/')[1]
      if seg in ['it', 'de'] then seg else 'en'
