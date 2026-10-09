# Compilation tasks: one per tool, each small enough to read in a minute.
path = require 'path'
fs = require 'fs'
CoffeeScript = require 'coffeescript'
Handlebars = require 'handlebars'
less = require 'less'
requirejs = require 'requirejs'

# Third-party libraries, copied as published (all UMD/AMD-aware).
VENDOR =
  'require.js': 'requirejs/require.js'
  'jquery.js': 'jquery/dist/jquery.js'
  'underscore.js': 'underscore/underscore-umd.js'
  'backbone.js': 'backbone/backbone.js'
  'handlebars.runtime.js': 'handlebars/dist/handlebars.runtime.js'
  'moment.js': 'moment/moment.js'
  'moment-locale/it.js': 'moment/locale/it.js'
  'moment-locale/de.js': 'moment/locale/de.js'

# Declaring our helpers lets Handlebars call them directly instead of
# emitting a defensive lookup for every mustache (a third of the bundle).
KNOWN_HELPERS = do ->
  out = {}
  out[name] = true for name in ['t', 'link', 'external', 'viewLink', 'icon', 'num', 'formatDate', 'eq', 'any', 'facultyName', 'levelName', 'concat', 'range', 'inc', 'years', 'join']
  out

FONTS = [
  '@fontsource-variable/fraunces/files/fraunces-latin-opsz-normal.woff2'
  '@fontsource-variable/fraunces/files/fraunces-latin-ext-opsz-normal.woff2'
  '@fontsource-variable/fraunces/files/fraunces-latin-opsz-italic.woff2'
  '@fontsource-variable/inter-tight/files/inter-tight-latin-wght-normal.woff2'
  '@fontsource-variable/inter-tight/files/inter-tight-latin-ext-wght-normal.woff2'
]

module.exports = (grunt) ->
  p = (key) -> grunt.config "paths.#{key}"
  mod = (rel) -> require.resolve rel

  grunt.registerTask 'clean', 'Remove the build folder.', ->
    grunt.file.delete p('build') if grunt.file.exists p('build')

  grunt.registerTask 'vendor', 'Copy vendor libraries and fonts.', ->
    for out, src of VENDOR
      grunt.file.copy mod(src), path.join(p('build'), 'js/vendor', out)
    for font in FONTS
      grunt.file.copy mod(font), path.join(p('build'), 'fonts', path.basename(font))
    grunt.log.ok "#{Object.keys(VENDOR).length} libraries, #{FONTS.length} fonts"

  grunt.registerTask 'coffee', 'Compile CoffeeScript to AMD modules.', ->
    files = grunt.file.expand { cwd: "#{p('src')}/coffee" }, '**/*.coffee'
    for rel in files
      source = grunt.file.read "#{p('src')}/coffee/#{rel}"
      try
        js = CoffeeScript.compile source, bare: true, filename: rel
      catch err
        grunt.fail.warn "#{rel}:#{(err.location?.first_line ? 0) + 1}: #{err.message}"
      grunt.file.write path.join(p('build'), 'js', rel.replace(/\.coffee$/, '.js')), js
    grunt.log.ok "#{files.length} modules"

  grunt.registerTask 'templates', 'Precompile Handlebars templates into one AMD module.', ->
    root = "#{p('src')}/templates"
    files = grunt.file.expand { cwd: root }, '**/*.hbs'
    entries = for rel in files
      name = rel.replace /\.hbs$/, ''
      # Indentation is for humans: keep one newline, drop the leading spaces.
      source = grunt.file.read("#{root}/#{rel}").replace /\s*\n\s*/g, '\n'
      spec = Handlebars.precompile(source, preventIndent: true, knownHelpers: KNOWN_HELPERS, knownHelpersOnly: true)
        # Source locations only feed compiler error messages; don't ship them.
        .replace /,"loc":\{"start":\{"line":\d+,"column":\d+\},"end":\{"line":\d+,"column":\d+\}\}/g, ''
      "  #{JSON.stringify name}: Handlebars.template(#{spec})"
    grunt.file.write path.join(p('build'), 'js/templates.js'), """
      define(['handlebars.runtime'], function (Handlebars) {
        Handlebars = Handlebars['default'] || Handlebars;
        return {
      #{entries.join ',\n'}
        };
      });
    """
    grunt.log.ok "#{files.length} templates"

  grunt.registerTask 'styles', 'Compile LESS.', ->
    done = @async()
    file = "#{p('src')}/less/app.less"
    less.render(grunt.file.read(file), filename: path.resolve(file), compress: true, math: 'strict')
      .then (out) ->
        grunt.file.write path.join(p('build'), 'app.css'), out.css
        grunt.log.ok "app.css #{(out.css.length / 1024).toFixed 1} KB"
        done()
      .catch (err) ->
        grunt.fail.warn "#{err.filename}:#{err.line}: #{err.message}"
        done false

  grunt.registerTask 'bundle', 'Bundle every module with r.js.', ->
    done = @async()
    requirejs.optimize
      baseUrl: path.join(p('build'), 'js')
      mainConfigFile: path.join(p('build'), 'js/main.js')
      paths: requireLib: 'vendor/require'
      name: 'main'
      include: ['requireLib']
      insertRequire: ['main']
      out: path.join(p('build'), 'app.js')
      optimize: 'uglify'
      preserveLicenseComments: false
      logLevel: 2
    , ->
      grunt.log.ok "app.js #{(fs.statSync(path.join p('build'), 'app.js').size / 1024).toFixed 1} KB"
      done()
    , (err) ->
      grunt.fail.warn err
      done false

  # An unsealed page for development: same shell as the gate, loads the bundle directly.
  grunt.registerTask 'page', 'Write the unsealed development page.', ->
    shell = grunt.file.read "#{p('src')}/gate/shell.html"
    html = shell
      .replace('{{head}}', '<link rel="stylesheet" href="app.css">')
      .replace('{{body}}', '<div id="app"></div><script src="app.js"></script>')
    grunt.file.write path.join(p('build'), 'index.html'), html
