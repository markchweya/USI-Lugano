define ['lib/search'], (search) ->
  items = search.prepare [
    { title: 'Master in Artificial Intelligence', subtitle: 'Master · Informatics', body: 'Machine learning' }
    { title: 'Bachelor in Economics', subtitle: 'Bachelor · Economics', body: 'Markets and policy' }
    { title: 'Università della Svizzera italiana', subtitle: 'Home', body: 'Lugano' }
    { title: 'Housing', subtitle: 'University › Services', body: 'Rooms for students in Lugano' }
    { title: 'Housing', subtitle: 'University › Services', body: 'Duplicate listing' }
  ]

  (test, assert) ->
    test 'search: normalise strips accents, case and punctuation', ->
      assert.strictEqual search.normalise('Università — L’Aquila!'), 'universita laquila'

    test 'search: every term must match', ->
      assert.deepStrictEqual (r.title for r in search.run(items, 'master intelligence')), ['Master in Artificial Intelligence']
      assert.strictEqual search.run(items, 'master economics').length, 0

    test 'search: accent-insensitive', ->
      assert.strictEqual search.run(items, 'universita')[0].title, 'Università della Svizzera italiana'

    test 'search: title matches outrank body matches', ->
      results = search.run items, 'lugano'
      assert.ok results.length >= 2
      assert.strictEqual results[0].title, 'Housing'

    test 'search: duplicates are dropped', ->
      assert.strictEqual search.run(items, 'housing').length, 1

    test 'search: empty queries return nothing', ->
      assert.strictEqual search.run(items, '   ').length, 0
