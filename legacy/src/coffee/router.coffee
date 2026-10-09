# One splat route: the fragment is parsed by lib/paths so localised slugs and
# real usi.ch paths share a single, testable resolver.
define ['backbone', 'lib/paths', 'views/home', 'views/study', 'views/explore', 'views/page', 'views/colophon', 'views/not-found'],
(Backbone, paths, HomeView, StudyView, ExploreView, PageView, ColophonView, NotFoundView) ->
  VIEWS =
    home: HomeView
    study: StudyView
    explore: ExploreView
    colophon: ColophonView
    page: PageView

  Backbone.Router.extend
    routes:
      '*fragment': 'dispatch'

    initialize: (options) ->
      @app = options.app

    dispatch: (fragment, queryString) ->
      route = paths.parse fragment ? ''
      query = paths.parseQuery queryString
      switch route.view
        when 'root'
          return @app.go paths.home(@app.preferredLang()), replace: true
        when 'unknown'
          route.lang = @app.preferredLang()
          View = NotFoundView
        else
          View = VIEWS[route.view]
      @app.setLang route.lang
      @app.shell.show new View({ app: @app, route, query })
