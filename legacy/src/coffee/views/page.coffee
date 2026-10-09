# Any real usi.ch page: breadcrumb, header, typed content blocks, section
# navigation, a table of contents and quick links. German pages say they are
# translations; pages not yet translated fall back to the English original.
define ['jquery', 'underscore', 'views/base', 'templates', 'i18n/index', 'lib/paths', 'lib/format', 'lib/search', 'data/store'],
($, _, BaseView, templates, i18n, paths, format, search, store) ->
  slug = (text) -> search.normalise(text).replace(/\s+/g, '-').slice(0, 60) or 'section'

  BaseView.extend
    className: 'view view--page'

    events:
      'click .js-retry': 'render'
      'click .js-anchor': 'scrollToAnchor'
      'click .js-prose a[href^="#"]:not([href^="#/"])': 'scrollToAnchor'
      'click .js-video': 'playVideo'
      'click .js-slide-prev': (e) -> @slide e, -1
      'click .js-slide-next': (e) -> @slide e, 1

    title: -> @page?.title ? @entry?.title ? ''

    alternates: ->
      lang = i18n.lang()
      out = {}
      out[lang] = paths.page @route.path
      return _.defaults(out, _.object([l, paths.home l] for l in i18n.langs)) unless @page
      alt = _.extend {}, @page.alternates
      alt.en ?= @page.path if @page.lang is 'en'
      # German mirrors the English paths.
      alt.de ?= '/de' + alt.en.slice(3) if alt.en
      alt.en ?= '/en' + @route.path.slice(3) if lang is 'de'
      for l in i18n.langs when l isnt lang
        out[l] = if alt[l] then paths.page(alt[l]) else paths.home(l)
      out

    render: ->
      @$el.html @template 'page-loading', path: @route.path
      store.find(@route.path)
        .then (entry) =>
          @entry = entry
          return @missing() unless entry
          store.page(entry.id).then (page) => @show page
        .fail => @failed()
      this

    show: (page) ->
      return if @removed
      @page = page
      lang = i18n.lang()
      fallback = !!@entry.untranslated
      blocks = for block in page.blocks
        if block.t is 'h' then _.extend({ id: slug block.text }, block) else block
      # Unique ids for repeated headings.
      seen = {}
      for b in blocks when b.id
        b.id = "#{b.id}-#{seen[b.id]}" if seen[b.id]
        seen[b.id] = (seen[b.id] ? 0) + 1
      toc = ({ id: b.id, text: b.text } for b in blocks when b.t is 'h' and b.level is 2)
      original = if lang is 'de' then (page.alternates?.en ? '/en' + @route.path.slice(3)) else null
      @$el.html @template 'page',
        page: page
        blocks: blocks
        lang: lang
        crumbs: _.initial(page.breadcrumb ? [])
        nav: _.reject(page.nav ? [], (l) -> store.normalise(l.href) is page.path)
        toc: if toc.length > 1 then toc else null
        links: (page.links ? []).slice 0, 12
        ctas: page.ctas ? []
        translated: lang is 'de' and not fallback
        fallback: fallback
        original: original
        synced: format.date page.fetchedAt, lang
        thin: blocks.length < 2 and (page.nav ? []).length > 3
      @enhance()
      @ready()

    # Real content links become app links when we have the page; images load lazily.
    enhance: ->
      lang = i18n.lang()
      @$('.js-prose a[href]').each (_i, a) ->
        href = a.getAttribute 'href'
        href = href.replace /^https?:\/\/(www\.)?usi\.ch/, '' if /^https?:\/\/(www\.)?usi\.ch\//.test href
        return unless href.charAt(0) is '/'
        target = store.resolve href, lang
        a.setAttribute 'href', target.href
        $(a).addClass('is-external').attr('rel', 'noopener') unless target.internal
      @$('.js-prose img').attr { loading: 'lazy', decoding: 'async' }
      @$('.js-prose table').wrap '<div class="table-scroll" tabindex="0"></div>'
      @$('.js-carousel').each (_i, el) => @updateSlides $(el)

    missing: ->
      lang = i18n.lang()
      usi = if lang is 'de' then '/en' + @route.path.slice(3) else @route.path
      @$el.html @template 'page-missing',
        original: "https://www.usi.ch#{usi}"
        search: paths.view 'explore', lang, q: _.last(@route.path.split('/')).replace(/[-_]+/g, ' ')
      @ready()

    failed: ->
      return if @removed
      @$el.html @template 'page-error'
      @ready()

    scrollToAnchor: (e) ->
      id = $(e.currentTarget).data('target') ? $(e.currentTarget).attr('href').slice(1)
      $target = @$("[id='#{id.replace /'/g, ''}']")
      return unless $target.length
      e.preventDefault()
      $target.attr('tabindex', '-1')[0].scrollIntoView behavior: 'smooth', block: 'start'
      $target.trigger 'focus', preventScroll: true

    # YouTube facade: nothing loads from YouTube until the visitor asks for it.
    playVideo: (e) ->
      $btn = $(e.currentTarget)
      id = String($btn.data 'youtube').replace /[^\w-]/g, ''
      $frame = $('<iframe allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>')
        .attr
          src: "https://www.youtube-nocookie.com/embed/#{id}?autoplay=1&rel=0"
          title: $btn.attr('aria-label')
      $btn.replaceWith $frame
      $frame.trigger 'focus'

    slide: (e, dir) ->
      $carousel = $(e.currentTarget).closest '.js-carousel'
      track = $carousel.find('.js-track')[0]
      track.scrollBy left: dir * track.clientWidth, behavior: 'smooth'
      _.delay (=> @updateSlides $carousel), 450

    updateSlides: ($carousel) ->
      track = $carousel.find('.js-track')[0]
      return unless track
      n = $carousel.find('.slide').length
      i = Math.round(track.scrollLeft / Math.max(track.clientWidth, 1))
      $carousel.find('.js-slide-count').text i18n.t('page.slideOf', i + 1, n)
      $carousel.find('.js-slide-prev').prop 'disabled', i <= 0
      $carousel.find('.js-slide-next').prop 'disabled', i >= n - 1
      unless $carousel.data 'bound'
        $carousel.data 'bound', true
        $(track).on 'scroll', _.debounce((=> @updateSlides $carousel), 120)

    remove: ->
      @removed = true
      BaseView::remove.apply this, arguments
