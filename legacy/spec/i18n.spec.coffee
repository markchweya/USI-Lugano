# Every language has exactly the English keys, with the same value types.
define ['underscore', 'i18n/index'], (_, i18n) ->
  shape = (node, prefix = '') ->
    out = {}
    for own key, value of node
      name = if prefix then "#{prefix}.#{key}" else key
      if _.isObject(value) and not _.isFunction(value) and not _.isArray(value)
        _.extend out, shape(value, name)
      else
        out[name] = if _.isFunction(value) then "function/#{value.length}" else (if _.isArray(value) then "array/#{value.length}" else typeof value)
    out

  (test, assert) ->
    en = shape i18n.dicts.en

    for lang in ['it', 'de']
      do (lang) ->
        test "i18n: #{lang} has the same keys and types as en", ->
          assert.deepStrictEqual shape(i18n.dicts[lang]), en

    test 'i18n: German uses Swiss spelling (no ß)', ->
      text = JSON.stringify i18n.dicts.de, (k, v) -> if _.isFunction(v) then v('X', 'Y') else v
      assert.strictEqual text.indexOf('ß'), -1

    test 'i18n: lookups interpolate and fall back to English', ->
      i18n.set 'it'
      assert.strictEqual i18n.t('study.count', 1), '1 corso'
      assert.strictEqual i18n.t('study.count', 3), '3 corsi'
      assert.strictEqual i18n.t('no.such.key'), 'no.such.key'
      i18n.set 'de'
      assert.strictEqual i18n.t('home.levelOption', 'Doktorat'), 'ein Doktorat'
      assert.strictEqual i18n.t('home.levelOption', 'Master'), 'einen Master'
      i18n.set 'en'
