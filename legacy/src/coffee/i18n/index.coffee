# The active language and dotted-key lookups: t('home.study.lede', 46).
define ['underscore', 'i18n/en', 'i18n/it', 'i18n/de'], (_, en, it, de) ->
  dicts = { en, it, de }
  current = 'en'

  lookup = (dict, key) ->
    _.reduce key.split('.'), ((node, part) -> node?[part]), dict

  i18n =
    langs: ['en', 'it', 'de']
    dicts: dicts
    names: { en: 'English', it: 'Italiano', de: 'Deutsch' }
    isLang: (l) -> _.has dicts, l
    set: (l) -> current = l if i18n.isLang l
    lang: -> current
    m: -> dicts[current]
    t: (key, args...) ->
      value = lookup(dicts[current], key) ? lookup(dicts.en, key)
      if _.isFunction value then value(args...) else value ? key
