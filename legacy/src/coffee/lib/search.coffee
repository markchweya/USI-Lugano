# The search engine: accent-insensitive, multi-word, ranked. Pure functions on
# plain objects, so it runs in Node for the specs exactly as in the browser.
define ['underscore'], (_) ->
  normalise = (s) ->
    String(s ? '')
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .toLowerCase()
      .replace(/[’'`]/g, '')
      .replace(/[^a-z0-9]+/g, ' ')
      .trim()

  tokens = (q) -> _.uniq _.compact normalise(q).split(' ')

  # Points for one term against one prepared item; 0 means the term is missing.
  scoreTerm = (item, term) ->
    if item._title is term then 120
    else if item._title.indexOf(term) is 0 then 80
    else if (' ' + item._title).indexOf(' ' + term) >= 0 then 60
    else if item._title.indexOf(term) >= 0 then 35
    else if (' ' + item._sub).indexOf(' ' + term) >= 0 then 20
    else if item._body.indexOf(term) >= 0 then 8
    else 0

  search =
    normalise: normalise
    tokens: tokens

    # items: [{ title, subtitle, body, boost? }] → prepared copies (do this once per index).
    prepare: (items) ->
      for item in items
        _.extend {}, item,
          _title: normalise item.title
          _sub: normalise item.subtitle
          _body: normalise item.body

    # Every term must match somewhere. Shorter titles win ties; duplicates are dropped.
    run: (prepared, query, limit = 20) ->
      terms = tokens query
      return [] unless terms.length
      hits = []
      for item in prepared
        total = 0
        for term in terms
          s = scoreTerm item, term
          break unless s
          total += s
        continue unless s
        total += item.boost ? 0
        total -= item._title.length / 40
        hits.push { item, score: total }
      hits.sort (a, b) -> b.score - a.score
      seen = {}
      out = []
      for hit in hits
        key = "#{hit.item._title}|#{hit.item._sub}"
        continue if seen[key]
        seen[key] = true
        out.push hit.item
        break if out.length >= limit
      out
