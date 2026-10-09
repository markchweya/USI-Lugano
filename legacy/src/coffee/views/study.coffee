# The programme finder. Filters live in a Backbone model that mirrors the URL;
# results re-render on every change without re-rendering the form.
define ['jquery', 'underscore', 'views/base', 'templates', 'i18n/index', 'lib/paths', 'data/store', 'data/static', 'models/finder', 'collections/programmes'],
($, _, BaseView, templates, i18n, paths, store, statics, Finder, Programmes) ->
  BaseView.extend
    className: 'view view--study'

    events:
      'input .js-q': 'onSearch'
      'change .js-filter': 'onFilter'
      'click .js-reset': 'reset'
      'submit form': (e) -> e.preventDefault()

    setup: ->
      @state = new Finder().fromQuery @query, statics.faculties
      # Debounce, then re-bind: Backbone delegated the events before setup ran.
      @onSearch = _.debounce @onSearch, 150
      @delegateEvents()
      @listenTo @state, 'change', @update

    title: -> i18n.t 'study.title'

    alternates: ->
      _.object ([l, paths.view('study', l, @state.toQuery())] for l in i18n.langs)

    render: ->
      @$el.html @template 'study',
        state: @state.toJSON()
        levels: ({ key, label: i18n.m().levels[key], checked: @state.get('level') is key } for key in ['bachelor', 'master'])
        faculties: ({ slug, name: i18n.m().faculties[slug].short, selected: @state.get('faculty') is slug } for slug in statics.faculties)
        taught: [
          { key: 'EN', label: i18n.t('study.english'), checked: @state.get('taught') is 'EN' }
          { key: 'IT', label: i18n.t('study.italian'), checked: @state.get('taught') is 'IT' }
        ]
      store.programmes()
        .then (all) =>
          @programmes = Programmes.forLang all, i18n.lang()
          @renderResults()
        .fail => @$('.js-results').html templates['load-error']()
      this

    renderResults: ->
      return unless @programmes
      list = @programmes.filtered @state
      @$('.js-count').text i18n.t('study.count', list.length)
      @$('.js-reset').prop 'hidden', @state.isEmpty()
      @$('.js-results').html templates['study-results']
        programmes: _.invoke list, 'toJSON'
        lang: i18n.lang()
        empty: not list.length

    update: ->
      @app.replaceUrl paths.view('study', i18n.lang(), @state.toQuery())
      @renderResults()
      @trigger 'ready'

    onSearch: ->
      @state.set q: @$('.js-q').val().trim()

    onFilter: (e) ->
      $input = $(e.currentTarget)
      @state.set $input.attr('name'), $input.val()

    reset: ->
      @state.clear(silent: true).set(@state.defaults)
      @render()
      @$('.js-q').trigger 'focus'
