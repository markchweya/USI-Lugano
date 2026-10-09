# Handlebars helpers: i18n, links, numbers, dates and icons. Registered once on
# the runtime; partials are any template under partials/.
define ['handlebars.runtime', 'underscore', 'templates', 'i18n/index', 'lib/paths', 'lib/format', 'lib/icons', 'data/store'],
(Handlebars, _, templates, i18n, paths, format, icon, store) ->
  Handlebars = Handlebars['default'] ? Handlebars
  { SafeString } = Handlebars

  # Handlebars appends an options object to every helper call.
  args = (list) -> _.initial list

  helpers =
    t: (key, rest...) -> i18n.t key, args(rest)...
    # Names are chosen not to shadow template data: {{href}} must stay a field.
    link: (path) -> store.resolve(path, i18n.lang()).href
    external: (path) -> not store.resolve(path, i18n.lang()).internal
    viewLink: (name, options) -> paths.view name, i18n.lang(), options.hash
    icon: (name, size) -> new SafeString icon(name, if _.isNumber(size) then size else undefined)
    num: (n) -> format.number n
    formatDate: (value) -> format.date value, i18n.lang()
    eq: (a, b) -> a is b
    any: (list...) -> _.some args(list)
    facultyName: (slug, field) -> i18n.m().faculties[slug]?[if _.isString(field) then field else 'name'] ? ''
    levelName: (slug) -> i18n.m().levels[slug] ? slug
    concat: (list...) -> args(list).join ''
    range: (n) -> [0...n]
    inc: (n) -> n + 1
    years: (semesters) -> format.years semesters
    join: (list, sep) -> (list ? []).join(if _.isString(sep) then sep else ', ')

  Handlebars.registerHelper name, fn for name, fn of helpers
  for name, tpl of templates when name.indexOf('partials/') is 0
    Handlebars.registerPartial name.slice('partials/'.length), tpl

  helpers
