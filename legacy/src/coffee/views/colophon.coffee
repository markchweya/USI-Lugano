# The colophon: what this edition is built with and why.
define ['underscore', 'views/base', 'i18n/index', 'lib/paths', 'data/stack'], (_, BaseView, i18n, paths, stack) ->
  BaseView.extend
    className: 'view view--colophon'

    title: -> i18n.t 'colophon.title'

    render: ->
      m = i18n.m().colophon
      @$el.html @template 'colophon',
        stack: for item, i in stack
          _.extend { n: i + 1, role: m.stack[item.key].role, better: m.stack[item.key].better, era: i18n.t('colophon.era', item.year) }, item
        principles: m.principleList
        home: paths.home i18n.lang()
      this
