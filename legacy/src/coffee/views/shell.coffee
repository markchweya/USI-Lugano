# The page frame: header, footer, search dialog and the region routed views
# render into. Owns focus management and route announcements.
define ['jquery', 'underscore', 'backbone', 'templates', 'i18n/index', 'lib/paths', 'lib/format', 'data/store', 'views/search'],
($, _, Backbone, templates, i18n, paths, format, store, SearchView) ->
  THEME_ICONS = { system: 'system', light: 'sun', dark: 'moon' }

  Backbone.View.extend
    events:
      'click .js-skip': 'skip'
      'click .js-theme': 'cycleTheme'
      'click .js-search-open': 'openSearch'
      'click .js-menu': 'toggleMenu'
      'click .js-lock': 'lock'
      'click .js-nav a': 'closeMenu'

    initialize: (options) ->
      @app = options.app
      @first = true
      @listenTo @app, 'lang', @renderFrame
      @listenTo @app.prefs, 'change:theme', @renderHeader
      $(document).on 'keydown.shell', _.bind(@hotkeys, this)

    render: ->
      @$el.html templates.shell()
      @$header = @$('.js-header')
      @$main = @$('#main')
      @$footer = @$('.js-footer')
      @$announcer = @$('.js-announcer')
      @search = new SearchView(app: @app, el: @$('.js-search'))
      @renderFrame()
      this

    renderFrame: ->
      @renderHeader()
      @renderFooter()

    navItems: ->
      lang = i18n.lang()
      current = @current?.route ? {}
      items = [{ label: i18n.t('nav.programmes'), href: paths.view('study', lang), active: current.view is 'study' }]
      for key in ['research', 'innovation', 'university']
        root = paths.SECTIONS[key][lang]
        items.push
          label: i18n.m().sections[key].label
          href: paths.page root
          active: current.view is 'page' and current.path? and (current.path is root or current.path.indexOf("#{root}/") is 0)
      items.push { label: i18n.t('nav.explore'), href: paths.view('explore', lang), active: current.view is 'explore' }
      items

    renderHeader: ->
      theme = @app.prefs.get 'theme'
      alternates = @current?.alternates() ? {}
      @$header.html templates.header
        lang: i18n.lang()
        home: paths.home i18n.lang()
        nav: @navItems()
        langs: for code in i18n.langs
          { code, name: i18n.names[code], href: alternates[code] ? paths.home(code), current: code is i18n.lang() }
        themeIcon: THEME_ICONS[theme]
        themeLabel: i18n.t 'theme.change', i18n.t("theme.#{theme}")
        sealed: @app.sealed
        menuOpen: @menuOpen

    renderFooter: ->
      lang = i18n.lang()
      data =
        lang: lang
        year: new Date().getFullYear()
        sealed: @app.sealed
        sections: ({ label: i18n.m().sections[key].label, href: paths.page paths.SECTIONS[key][lang] } for key in paths.sectionKeys)
        colophon: paths.view 'colophon', lang
        explore: paths.view 'explore', lang
        study: paths.view 'study', lang
      @$footer.html templates.footer(data)
      store.stats().then (stats) =>
        count = stats["pages#{lang.charAt(0).toUpperCase()}#{lang.slice 1}"] ? stats.pages
        @$footer.find('.js-page-count').text i18n.t('footer.exploreAll', format.number count)

    # Swap the routed view. Old views are removed, which also unbinds their events.
    show: (view) ->
      @current?.remove()
      @current = view
      @closeMenu()
      @search.close()
      @listenTo view, 'ready', @refresh
      @$main.empty().append view.el
      view.render()
      @refresh()
      if @first
        @first = false
      else
        window.scrollTo 0, 0
        @$main.trigger 'focus'
      this

    refresh: ->
      title = @current?.title()
      edition = "USI #{i18n.t 'meta.edition'}"
      document.title = if title then "#{title} · #{edition}" else "#{i18n.t 'meta.siteName'} · #{i18n.t 'meta.edition'}"
      @renderHeader()
      # Screen readers hear where they landed, once per navigation.
      @$announcer.text title or i18n.t('meta.siteName')

    skip: (e) ->
      e.preventDefault()
      @$main.trigger 'focus'

    cycleTheme: ->
      @app.prefs.save theme: @app.prefs.nextTheme()
      @$('.js-theme').trigger 'focus'

    openSearch: (e) ->
      e?.preventDefault()
      @search.open e?.currentTarget

    toggleMenu: ->
      @menuOpen = not @menuOpen
      @$header.find('.js-menu').attr('aria-expanded', String @menuOpen)
      @$header.toggleClass 'is-open', @menuOpen
      $('html').toggleClass 'is-menu-open', @menuOpen

    closeMenu: ->
      return unless @menuOpen
      @toggleMenu()

    lock: (e) ->
      e.preventDefault()
      @app.lock()

    # "/" or Cmd/Ctrl+K opens search from anywhere except text fields.
    hotkeys: (e) ->
      typing = $(e.target).is('input, textarea, select, [contenteditable]')
      if (e.key is 'k' or e.key is 'K') and (e.metaKey or e.ctrlKey)
        e.preventDefault()
        @openSearch()
      else if e.key is '/' and not typing and not @search.isOpen
        e.preventDefault()
        @openSearch()
      else if e.key is 'Escape' and @menuOpen
        @closeMenu()

    remove: ->
      $(document).off '.shell'
      Backbone.View::remove.apply this, arguments
