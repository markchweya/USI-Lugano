# Home: hero with intent picker, key figures, programmes rail, faculties,
# events and the four areas of the site. Each block fills in as its data lands.
define ['jquery', 'underscore', 'views/base', 'templates', 'i18n/index', 'lib/paths', 'lib/format', 'data/store', 'data/static', 'collections/programmes'],
($, _, BaseView, templates, i18n, paths, format, store, statics, Programmes) ->
  reducedMotion = -> window.matchMedia?('(prefers-reduced-motion: reduce)').matches

  BaseView.extend
    className: 'view view--home'

    events:
      'submit .js-intent': 'findProgrammes'
      'click .js-rail-prev': -> @scrollRail -1
      'click .js-rail-next': -> @scrollRail 1

    render: ->
      lang = i18n.lang()
      @$el.html @template 'home',
        hero: statics.hero
        levels: ({ key, label: i18n.m().levels[key] } for key in ['bachelor', 'master'])
        faculties: ({ slug, name: i18n.m().faculties[slug].short } for slug in statics.faculties)
        facts: statics.facts
        portrait: statics.portrait[lang]
        study: paths.view 'study', lang
        explore: paths.view 'explore', lang
        colophon: paths.view 'colophon', lang
      # Scroll events don't bubble, so this one can't be delegated.
      @$('.js-rail').on 'scroll', _.throttle(_.bind(@updateRailButtons, this), 100)
      @countUp()
      @load()
      this

    load: ->
      lang = i18n.lang()
      store.programmes().then (all) =>
        list = Programmes.forLang all, lang
        @$('.js-study-lede').text i18n.t('home.study.lede', list.length)
        @$('.js-rail').html templates['home-rail'] { programmes: list.toJSON().slice(0, 12), lang }
        counts = list.countBy 'faculty'
        @$('.js-faculties').html templates['home-faculties']
          lang: lang
          faculties: for slug in statics.faculties
            slug: slug
            name: i18n.m().faculties[slug].name
            count: counts[slug] ? 0
            href: paths.view 'study', lang, faculty: slug
        @updateRailButtons()
      store.events().then (events) =>
        own = _.filter events, (e) -> e.lang is (if lang is 'it' then 'it' else 'en')
        @$('.js-events').html templates['home-events'] { events: own.slice(0, 6), lang }
      $.when(store.index(lang), store.stats()).then (entries, stats) =>
        local = store.entriesFor entries, lang
        @$('.js-search-hint').text i18n.t('home.searchHint', format.number local.length)
        @$('.js-areas-lede').text i18n.t('home.areas.lede', format.number(stats.pages), format.thousands(stats.words))
        depth = (p) -> p.split('/').length
        @$('.js-areas').html templates['home-areas']
          lang: lang
          areas: for key in paths.sectionKeys
            root = paths.SECTIONS[key][lang]
            inside = _.filter local, (e) -> e.path.indexOf("#{root}/") is 0
            label = i18n.m().sections[key].label
            key: key
            label: label
            blurb: i18n.m().sections[key].blurb
            count: format.number inside.length
            href: paths.view 'explore', lang, section: key
            allIn: i18n.t 'home.areas.allIn', label
            children: _.chain(inside).filter((e) -> depth(e.path) is depth(root) + 1).sortBy('title').first(6).value()

    findProgrammes: (e) ->
      e.preventDefault()
      form = @$('.js-intent')
      @app.go paths.view 'study', i18n.lang(),
        level: form.find('[name=level]').val()
        faculty: form.find('[name=faculty]').val()

    # Key figures count up once, when they scroll into view.
    countUp: ->
      $numbers = @$('.js-count')
      return if reducedMotion() or not window.IntersectionObserver
      $numbers.each (_i, el) ->
        $el = $(el)
        target = $el.data 'value'
        plain = $el.data('plain')?
        $el.text if plain then target else format.number(0)
        observer = new IntersectionObserver (entries) ->
          return unless entries[0].isIntersecting
          observer.disconnect()
          start = if plain then target - 30 else 0
          $({ n: start }).animate { n: target },
            duration: 1400
            easing: 'swing'
            step: (now) -> $el.text if plain then Math.round(now) else format.number(now)
            complete: -> $el.text if plain then target else format.number(target)
        , threshold: 0.6
        observer.observe el
        $el.data 'observer', observer

    scrollRail: (dir) ->
      rail = @$('.js-rail')[0]
      return unless rail
      rail.scrollBy left: dir * rail.clientWidth * 0.85, behavior: if reducedMotion() then 'auto' else 'smooth'

    updateRailButtons: ->
      rail = @$('.js-rail')[0]
      return unless rail
      @$('.js-rail-prev').prop 'disabled', rail.scrollLeft < 8
      @$('.js-rail-next').prop 'disabled', rail.scrollLeft + rail.clientWidth > rail.scrollWidth - 8

    remove: ->
      @$('.js-count').each (_i, el) -> $(el).data('observer')?.disconnect()
      BaseView::remove.apply this, arguments
