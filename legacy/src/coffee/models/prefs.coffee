# Viewer preferences (language, theme), persisted to localStorage through a
# custom Backbone.sync — storage can be unavailable, so every access is guarded.
define ['backbone', 'underscore'], (Backbone, _) ->
  KEYS = { lang: 'usi-legacy-lang', theme: 'usi-legacy-theme' }

  storage =
    get: (k) -> try window.localStorage.getItem(k) catch then null
    set: (k, v) ->
      try
        if v? then window.localStorage.setItem(k, v) else window.localStorage.removeItem(k)

  Backbone.Model.extend
    defaults:
      lang: null
      theme: 'system'

    sync: (method, model, options) ->
      if method is 'read'
        attrs = { lang: storage.get(KEYS.lang), theme: storage.get(KEYS.theme) ? 'system' }
        options.success? attrs
      else
        storage.set KEYS.lang, model.get('lang')
        # 'system' is the absence of a choice.
        storage.set KEYS.theme, (if model.get('theme') is 'system' then null else model.get('theme'))
        options.success? model.toJSON()
      null

    themes: ['system', 'light', 'dark']

    nextTheme: ->
      i = _.indexOf @themes, @get('theme')
      @themes[(i + 1) % @themes.length]

    resolvedTheme: ->
      theme = @get 'theme'
      return theme unless theme is 'system'
      if window.matchMedia?('(prefers-color-scheme: dark)').matches then 'dark' else 'light'
