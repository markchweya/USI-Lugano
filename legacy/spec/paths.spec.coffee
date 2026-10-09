define ['lib/paths'], (paths) ->
  (test, assert) ->
    test 'paths: localised view slugs round-trip', ->
      for lang in ['en', 'it', 'de']
        for view in ['study', 'explore', 'colophon']
          hash = paths.view view, lang
          parsed = paths.parse hash
          assert.strictEqual parsed.view, view, hash
          assert.strictEqual parsed.lang, lang

    test 'paths: content paths and roots', ->
      assert.deepStrictEqual paths.parse('it'), { lang: 'it', view: 'home' }
      assert.deepStrictEqual paths.parse(''), { lang: null, view: 'root' }
      assert.deepStrictEqual paths.parse('en/education/bachelor/'), { lang: 'en', view: 'page', path: '/en/education/bachelor' }
      assert.strictEqual paths.parse('fr/whatever').view, 'unknown'
      # A slug from another language is a content path, not a view.
      assert.strictEqual paths.parse('en/programmi').view, 'page'

    test 'paths: query strings', ->
      assert.strictEqual paths.view('study', 'en', { level: 'master', faculty: '', q: 'data science' }), '#/en/study?level=master&q=data%20science'
      assert.deepStrictEqual paths.parseQuery('level=master&q=data+science'), { level: 'master', q: 'data science' }
      assert.deepStrictEqual paths.parseQuery('q=%E0%A4%A'), {}

    test 'paths: sections', ->
      assert.strictEqual paths.sectionOf('/it/formazione/master'), 'education'
      assert.strictEqual paths.sectionOf('/de/university'), 'university'
      assert.strictEqual paths.sectionOf('/en/feeds/123'), 'other'
