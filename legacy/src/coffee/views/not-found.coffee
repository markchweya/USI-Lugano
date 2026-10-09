# Unknown routes.
define ['views/base', 'i18n/index', 'lib/paths'], (BaseView, i18n, paths) ->
  BaseView.extend
    className: 'view view--not-found'

    title: -> i18n.t 'notFound.title'

    alternates: ->
      en: paths.home('en'), it: paths.home('it'), de: paths.home('de')

    render: ->
      @$el.html @template 'not-found',
        home: paths.home i18n.lang()
        explore: paths.view 'explore', i18n.lang()
      this
