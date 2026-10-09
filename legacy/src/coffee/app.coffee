# The application object: preferences, language, theme and navigation. Views
# receive it as `options.app` instead of importing it, so there are no cycles.
define ['jquery', 'underscore', 'backbone', 'i18n/index', 'models/prefs', 'router', 'views/shell', 'helpers'],
($, _, Backbone, i18n, Prefs, Router, ShellView) ->
  App = _.extend {}, Backbone.Events,
    start: ->
      @sealed = !!window.USI_LEGACY?.sealed
      @prefs = new Prefs()
      @prefs.fetch()
      @applyTheme()
      @listenTo @prefs, 'change:theme', @applyTheme
      media = window.matchMedia?('(prefers-color-scheme: dark)')
      media?.addEventListener? 'change', => @applyTheme() if @prefs.get('theme') is 'system'

      @setLang @preferredLang(), silent: true
      root = $('#app')
      root = $('<div id="app"></div>').appendTo(document.body) unless root.length
      @shell = new ShellView(el: root, app: this).render()
      @router = new Router(app: this)
      Backbone.history.start()

    preferredLang: ->
      stored = @prefs.get 'lang'
      return stored if i18n.isLang stored
      return window.USI_LEGACY.lang if i18n.isLang window.USI_LEGACY?.lang
      for l in (navigator.languages ? [navigator.language ? 'en'])
        short = String(l).slice(0, 2).toLowerCase()
        return short if i18n.isLang short
      'en'

    setLang: (lang, options = {}) ->
      return unless i18n.isLang(lang)
      changed = lang isnt i18n.lang()
      i18n.set lang
      document.documentElement.lang = lang
      @prefs.save { lang }
      @trigger 'lang', lang if changed and not options.silent

    applyTheme: ->
      document.documentElement.setAttribute 'data-theme', @prefs.resolvedTheme()

    # Hash navigation. `replace` swaps the history entry instead of adding one.
    go: (hash, options = {}) ->
      if options.replace then location.replace(hash) else location.hash = hash

    # Update the URL without re-routing (finder filters, explore search).
    replaceUrl: (hash) ->
      return if location.hash is hash
      history.replaceState?(null, '', hash)
      # Keep Backbone's idea of the current fragment in step, or a later click
      # on the original URL would be ignored as "no change".
      Backbone.history.fragment = Backbone.history.getFragment()

    lock: ->
      try window.sessionStorage.removeItem 'usi-legacy-key'
      location.reload()
