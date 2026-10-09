# Content access. The corpus is the main site's /content folder, fetched lazily
# with jQuery Ajax and memoised as promises: one index per language, one JSON
# file per page.
define ['jquery', 'underscore', 'lib/paths'], ($, _, paths) ->
  BASE = '../content/'
  memo = {}
  byPath = {}

  # Failed requests are forgotten so the next call retries.
  getJSON = (file) ->
    unless memo[file]
      memo[file] = $.ajax(url: BASE + file, dataType: 'json', cache: true).then (data) -> data
      memo[file].fail -> delete memo[file]
    memo[file]

  store =
    BASE: BASE

    index: (lang) ->
      getJSON("index.#{lang}.json").then (entries) ->
        byPath[e.path] = e for e in entries
        entries

    page: (id) -> getJSON "pages/#{id}.json"
    programmes: -> getJSON 'programmes.json'
    events: -> getJSON 'events.json'
    stats: -> getJSON 'stats.json'

    find: (path) ->
      clean = store.normalise path
      store.index(paths.langOf clean).then -> byPath[clean]

    # Synchronous: only meaningful once the relevant index has loaded.
    known: (path) -> _.has byPath, store.normalise(path)

    normalise: (path) ->
      clean = String(path).split(/[?#]/)[0].replace(/\/+$/, '')
      try clean = decodeURI clean
      clean or '/'

    # A link inside real content: our page if we have it, otherwise usi.ch.
    resolve: (href, lang) ->
      return { internal: false, href: href } unless href and href.charAt(0) is '/'
      if lang is 'de' and href.indexOf('/en/') is 0
        de = '/de' + href.slice(3)
        return { internal: true, href: paths.page store.normalise(de) } if store.known de
      if store.known href
        { internal: true, href: paths.page store.normalise(href) }
      else
        { internal: false, href: "https://www.usi.ch#{href}" }

    # Entries under a language prefix (the German index also lists English pages awaiting translation).
    entriesFor: (entries, lang) ->
      _.filter entries, (e) -> e.path is "/#{lang}" or e.path.indexOf("/#{lang}/") is 0
