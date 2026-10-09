# Explore: every page in the current language, by section, filterable, in
# pages of 24 so long lists stay fast.
define ['jquery', 'underscore', 'views/base', 'templates', 'i18n/index', 'lib/paths', 'lib/format', 'lib/search', 'data/store'],
($, _, BaseView, templates, i18n, paths, format, search, store) ->
  PAGE = 24

  BaseView.extend
    className: 'view view--explore'

    events:
      'input .js-q': 'onSearch'
      'click .js-tab': 'onTab'
      'keydown .js-tab': 'onTabKey'
      'click .js-more': 'more'
      'submit form': (e) -> e.preventDefault()

    setup: ->
      @section = if @query.section in paths.sectionKeys.concat(['other']) then @query.section else ''
      @q = (@query.q ? '').slice 0, 80
      @limit = PAGE
      @onSearch = _.debounce @onSearch, 120
      @delegateEvents()

    title: -> i18n.t 'explore.title'

    alternates: ->
      _.object ([l, paths.view('explore', l, @queryState())] for l in i18n.langs)

    queryState: -> _.pick { section: @section, q: @q }, (v) -> v

    render: ->
      @$el.html @template 'explore', q: @q
      store.index(i18n.lang())
        .then (entries) =>
          @entries = store.entriesFor entries, i18n.lang()
          @prepared = search.prepare(for e in @entries
            _.extend { subtitle: e.crumbs.join(' '), body: e.description }, e)
          store.stats().then (stats) =>
            @$('.js-heading-a').text i18n.t('explore.headingA', format.number @entries.length)
            @$('.js-lede').text i18n.t('explore.lede', format.thousands stats.words)
          @renderTabs()
          @renderList()
        .fail =>
          @$('.js-list').html templates['load-error']()
      this

    tabs: ->
      counts = _.countBy @entries, (e) -> paths.sectionOf e.path
      all = [{ key: '', label: i18n.t('explore.everything'), count: @entries.length }]
      keys = paths.sectionKeys.concat ['other']
      all.concat({ key, label: i18n.m().sections[key].label, count: counts[key] ? 0 } for key in keys when counts[key])

    renderTabs: ->
      @$('.js-tabs').html templates['explore-tabs']
        tabs: ({ key: t.key, label: t.label, count: format.number(t.count), selected: t.key is @section } for t in @tabs())

    matches: ->
      inSection = (e) => not @section or paths.sectionOf(e.path) is @section
      if search.tokens(@q).length
        _.filter search.run(@prepared, @q, 2000), inSection
      else
        # Translated before untranslated, shallow before deep, then by title.
        key = (e) -> [(if e.untranslated then 1 else 0), (100 + e.path.split('/').length), e.title.toLowerCase()].join(' ')
        _.sortBy _.filter(@entries, inSection), key

    renderList: ->
      list = @matches()
      shown = list.slice 0, @limit
      @$('.js-count').text i18n.t('explore.count', format.number list.length)
      @$('.js-list').html templates['explore-list']
        entries: shown
        lang: i18n.lang()
        empty: not list.length
        more: if list.length > shown.length then i18n.t('explore.left', format.number list.length - shown.length) else null

    sync: ->
      @limit = PAGE
      @app.replaceUrl paths.view('explore', i18n.lang(), @queryState())
      @renderList()
      @trigger 'ready'

    onSearch: ->
      @q = @$('.js-q').val().trim()
      @sync()

    onTab: (e) ->
      @section = $(e.currentTarget).data('key') ? ''
      @renderTabs()
      @sync()
      @$(".js-tab[data-key='#{@section}']").trigger 'focus'

    # Arrow keys move between tabs (WAI-ARIA tabs pattern).
    onTabKey: (e) ->
      return unless e.key in ['ArrowLeft', 'ArrowRight', 'Home', 'End']
      e.preventDefault()
      $tabs = @$('.js-tab')
      i = $tabs.index e.currentTarget
      next = switch e.key
        when 'ArrowLeft' then (i - 1 + $tabs.length) % $tabs.length
        when 'ArrowRight' then (i + 1) % $tabs.length
        when 'Home' then 0
        else $tabs.length - 1
      $tabs.eq(next).trigger 'click'

    more: ->
      first = @limit
      @limit += PAGE * 2
      @renderList()
      # Move focus to the first newly shown item so keyboard users keep their place.
      @$('.js-list .entry-card a').eq(first).trigger 'focus'
