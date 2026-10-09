# A deliberately tiny test runner: specs are CoffeeScript AMD modules that
# receive `test` and `assert`, loaded through RequireJS's Node adapter, so the
# exact modules that ship are the ones under test.
path = require 'path'
assert = require 'assert'
CoffeeScript = require 'coffeescript'
requirejs = require 'requirejs'

module.exports = (grunt) ->
  p = (key) -> grunt.config "paths.#{key}"

  grunt.registerTask 'spec', 'Run ./spec/*.spec.coffee.', ->
    done = @async()
    specs = grunt.file.expand 'spec/*.spec.coffee'
    for file in specs
      js = CoffeeScript.compile grunt.file.read(file), bare: true, filename: file
      grunt.file.write path.join(p('build'), 'js/spec', path.basename(file, '.coffee') + '.js'), js

    # Reuse main.js's module paths by running its config call against a stub.
    config = null
    new Function('requirejs', 'define', grunt.file.read path.join(p('build'), 'js/main.js'))(
      { config: (c) -> config = c }, (->)
    )
    req = requirejs.config
      context: "spec-#{Date.now()}"
      baseUrl: path.resolve p('build'), 'js'
      paths: config.paths
      nodeRequire: require

    tests = []
    test = (name, fn) -> tests.push { name, fn }
    names = ("spec/#{path.basename f, '.coffee'}" for f in specs)

    req names, (modules...) ->
      mod(test, assert) for mod in modules
      failed = 0
      for t in tests
        try
          t.fn()
          grunt.log.writeln "  ✓ #{t.name}"
        catch err
          failed++
          grunt.log.error "  ✗ #{t.name}\n    #{err.message}"
      if failed
        grunt.fail.warn "#{failed} of #{tests.length} specs failed."
        done false
      else
        grunt.log.ok "#{tests.length} specs passed."
        done()
    , (err) ->
      grunt.fail.warn err
      done false
