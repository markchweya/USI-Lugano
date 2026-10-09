# Shared behaviour for routed views: template rendering, document title,
# language alternates and teardown. Subclasses implement `render`.
define ['backbone', 'underscore', 'templates', 'i18n/index', 'lib/paths'], (Backbone, _, templates, i18n, paths) ->
  Backbone.View.extend
    tagName: 'div'
    className: 'view'

    initialize: (options) ->
      @app = options.app
      @route = options.route ? {}
      @query = options.query ? {}
      @setup?()

    template: (name, data = {}) ->
      tpl = templates[name]
      throw new Error("Missing template #{name}") unless tpl
      tpl _.extend({ lang: i18n.lang() }, data)

    # Title shown in the tab: "Page · USI Legacy Edition".
    title: -> ''

    # Where the language switcher should go: lang → hash. Views with their own
    # localised slug map to the same view; content pages override this.
    alternates: ->
      name = @route.view
      _.object ([l, paths.view(name, l, @query)] for l in i18n.langs)

    # Ask the shell to refresh title and switcher once async data has arrived.
    ready: -> @trigger 'ready', this

    # The first heading takes focus after navigation (see ShellView#show).
    focusTarget: -> @$('h1').first()
