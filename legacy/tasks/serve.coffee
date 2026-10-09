# Development server. Mirrors the GitHub Pages layout:
#
#   /legacy/*    the unsealed build (or ./sealed with --sealed)
#   /content/*   the main site's public content, plus its generated data files
#
# Source changes trigger a rebuild; refresh the browser to see them.
http = require 'http'
fs = require 'fs'
path = require 'path'
{ spawn } = require 'child_process'

TYPES =
  '.html': 'text/html; charset=utf-8'
  '.js': 'text/javascript; charset=utf-8'
  '.css': 'text/css; charset=utf-8'
  '.json': 'application/json; charset=utf-8'
  '.woff2': 'font/woff2'
  '.svg': 'image/svg+xml'

GENERATED = ['programmes.json', 'events.json', 'stats.json']

module.exports = (grunt) ->
  p = (key) -> path.resolve grunt.config("paths.#{key}")

  send = (res, file) ->
    fs.stat file, (err, stat) ->
      if err or not stat.isFile()
        res.writeHead 404, 'Content-Type': 'text/plain'
        return res.end 'Not found'
      res.writeHead 200, 'Content-Type': TYPES[path.extname file] ? 'application/octet-stream', 'Cache-Control': 'no-store'
      fs.createReadStream(file).pipe res

  # Resolve inside a root only; never serve anything outside it.
  within = (root, rel) ->
    file = path.join root, rel
    if file.indexOf(root) is 0 then file else null

  grunt.registerTask 'serve', 'Serve the build at http://localhost:9001/legacy/.', ->
    @async() # runs until interrupted
    port = parseInt(process.env.PORT ? '9001', 10)
    site = if grunt.option('sealed') then p('sealed') else p('build')

    server = http.createServer (req, res) ->
      url = decodeURIComponent req.url.split('?')[0]
      if url is '/' or url is '/legacy'
        res.writeHead 302, Location: '/legacy/'
        return res.end()
      if url.indexOf('/legacy/') is 0
        rel = url.slice('/legacy/'.length) or 'index.html'
        return send res, within(site, rel) ? ''
      if url.indexOf('/content/') is 0
        rel = url.slice '/content/'.length
        root = if rel in GENERATED then p('generated') else p('content')
        return send res, within(root, rel) ? ''
      send res, ''

    server.listen port, ->
      grunt.log.ok "Serving #{path.relative process.cwd(), site}/ at http://localhost:#{port}/legacy/"

    return if grunt.option 'sealed'
    timer = null
    building = false
    fs.watch p('src'), { recursive: true }, ->
      clearTimeout timer
      timer = setTimeout ->
        return if building
        building = true
        child = spawn process.execPath, [require.resolve('grunt/bin/grunt'), 'build'], stdio: 'inherit'
        child.on 'exit', -> building = false
      , 150
