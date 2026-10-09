define ['lib/format'], (format) ->
  (test, assert) ->
    test 'format: Swiss thousands separator', ->
      assert.strictEqual format.number(4749), '4’749'
      assert.strictEqual format.number(550212), '550’212'
      assert.strictEqual format.number(115), '115'

    test 'format: localised dates', ->
      assert.strictEqual format.date('2026-10-08T15:08:58Z', 'en'), 'October 8, 2026'
      assert.strictEqual format.date('2026-10-08T15:08:58Z', 'it'), '8 ottobre 2026'
      assert.strictEqual format.date('2026-10-08T15:08:58Z', 'de'), '8. Oktober 2026'
      assert.strictEqual format.date('not a date', 'en'), ''
