# The search dialog (/ or Cmd/Ctrl+K): a combobox over programmes and every
# page in the current language, with full keyboard support.
define ['jquery', 'underscore', 'backbone', 'templates', 'i18n/index', 'lib/paths', 'lib/search', 'lib/format', 'data/store'],
($, _, Backbone, templates, i18n, paths, search, format, store) ->
  prepared = {}

  # Build (once per language) the searchable items.
  indexFor = (lang) ->
    prepared[lang] ?= $.when(store.index(lang), store.programmes()).then (entries, programmes) ->
      m = i18n.dicts[lang]
      progs = for p in _.uniq(_.filter(programmes, (p) -> p.lang is lang), false, (p) -> p.path)
        title: p.fullTitle
        subtitle: [m.levels[p.level], m.faculties[p.faculty]?.short].filter(Boolean).join(' · ')
        body: "#{p.title} #{p.summary}"
        href: paths.page p.path
        kind: 'programmes'
        boost: 25
      pages = for e in store.entriesFor(entries, lang)
        title: e.title
        subtitle: e.crumbs.join(' › ')
        body: e.description
        href: paths.page e.path
        kind: 'pages'
      { items: search.prepare(progs.concat pages), programmes: progs, count: pages.length }
    prepared[lang]

  Backbone.View.extend
    events:
      'input .js-q': 'onInput'
      'keydown .js-q': 'onKey'
      'click .js-close': 'close'
      'keydown .js-close': 'onCloseKey'
      'click .js-backdrop': 'close'
      'mousemove .js-option': 'hover'
      'click .js-option': 'choose'

    initialize: (options) ->
      @app = options.app
      @isOpen = false
      @active = 0
      @debouncedRun = _.debounce _.bind(@run, this), 60

    open: (opener) ->
      return @$q.trigger('focus') if @isOpen
      @opener = opener ? document.activeElement
      @isOpen = true
      @lang = i18n.lang()
      @$el.html templates.search()
      @$q = @$('.js-q')
      @$list = @$('.js-results')
      @$status = @$('.js-status')
      $('html').addClass 'is-locked'
      @$el.addClass 'is-open'
      @$q.trigger 'focus'
      @$status.text i18n.t('search.loading')
      indexFor(@lang)
        .then (data) =>
          return unless @isOpen
          @data = data
          @$status.text i18n.t('search.indexed', format.number data.count)
          @run()
        .fail =>
          @$status.text i18n.t('explore.failed')
      this

    close: ->
      return unless @isOpen
      @isOpen = false
      @$el.removeClass('is-open').empty()
      $('html').removeClass 'is-locked'
      $(@opener).trigger('focus') if @opener and document.body.contains(@opener)

    onInput: -> @debouncedRun()

    run: ->
      return unless @data
      q = @$q.val()
      lang = @lang
      if search.tokens(q).length
        hits = search.run @data.items, q, 24
        groups = _.chain(hits).groupBy('kind').map((items, kind) -> { label: i18n.t("search.groups.#{kind}"), items }).sortBy((g) -> if g.items[0].kind is 'programmes' then 0 else 1).value()
        @hits = _.flatten _.pluck(groups, 'items')
      else
        shortcuts = for key in ['study', 'explore', 'colophon']
          title: i18n.t "search.shortcuts.#{key}.title"
          subtitle: i18n.t "search.shortcuts.#{key}.subtitle"
          href: paths.view key, lang
          kind: 'goto'
        popular = @data.programmes.slice 0, 5
        groups = [
          { label: i18n.t('search.groups.goto'), items: shortcuts }
          { label: i18n.t('search.groups.programmes'), items: popular }
        ]
        @hits = shortcuts.concat popular
      # Number options in display order so arrow keys follow what is on screen.
      i = 0
      for g in groups
        for item in g.items
          item.index = i++
      @active = 0
      @$list.html templates['search-results']
        groups: groups
        query: q
        empty: not @hits.length
      @highlight()

    highlight: ->
      $options = @$('.js-option')
      $options.removeClass('is-active').attr 'aria-selected', 'false'
      $current = $options.eq(@active).addClass('is-active').attr('aria-selected', 'true')
      if $current.length
        @$q.attr 'aria-activedescendant', $current.attr('id')
        $current[0].scrollIntoView? block: 'nearest'
      else
        @$q.removeAttr 'aria-activedescendant'

    onKey: (e) ->
      n = @hits?.length ? 0
      switch e.key
        when 'ArrowDown'
          e.preventDefault()
          @active = (@active + 1) % n if n
          @highlight()
        when 'ArrowUp'
          e.preventDefault()
          @active = (@active - 1 + n) % n if n
          @highlight()
        when 'Enter'
          e.preventDefault()
          @go @hits?[@active]
        when 'Escape'
          e.preventDefault()
          @close()
        when 'Tab'
          # Keep focus inside the dialog: the input and the close button.
          e.preventDefault()
          @$('.js-close').trigger 'focus'

    onCloseKey: (e) ->
      if e.key is 'Tab'
        e.preventDefault()
        @$q.trigger 'focus'
      else if e.key is 'Escape'
        @close()

    hover: (e) ->
      index = $(e.currentTarget).data 'index'
      return if index is @active
      @active = index
      @highlight()

    choose: (e) ->
      e.preventDefault()
      @go @hits?[$(e.currentTarget).data 'index']

    go: (item) ->
      return unless item
      @close()
      @app.go item.href
