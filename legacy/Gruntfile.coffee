# USI — Legacy Edition build.
#
# Every step is a small task in ./tasks, written for this project:
#
#   grunt build    compile CoffeeScript, Handlebars and LESS, then bundle with r.js
#   grunt test     run the specs in ./spec against the compiled AMD modules
#   grunt dev      build, then serve an unsealed copy with live rebuilds
#   grunt seal     encrypt the bundle with LEGACY_PASSWORD into ./sealed (committed)
#   grunt verify   check that ./sealed was built from the current sources

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    paths:
      src: 'src'
      build: 'build'
      sealed: 'sealed'
      # The main site's public content and generated data, shared at runtime.
      content: '../public/content'
      generated: '../src/data/generated'

  grunt.loadTasks 'tasks'

  grunt.registerTask 'build', 'Compile and bundle the app.', ['clean', 'vendor', 'coffee', 'templates', 'styles', 'bundle', 'page']
  grunt.registerTask 'test', 'Run the specs.', ['clean', 'vendor', 'coffee', 'templates', 'spec']
  grunt.registerTask 'dev', 'Build and serve with live rebuilds.', ['build', 'serve']
  grunt.registerTask 'seal', 'Encrypt the bundle for publishing.', ['build', 'encrypt']
  grunt.registerTask 'verify', 'Check the sealed bundle is current.', ['build', 'check-seal']
  grunt.registerTask 'default', ['test', 'build']
