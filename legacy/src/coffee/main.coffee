# Entry point. r.js reads this config to bundle everything into one file.
requirejs.config
  paths:
    jquery: 'vendor/jquery'
    underscore: 'vendor/underscore'
    backbone: 'vendor/backbone'
    'handlebars.runtime': 'vendor/handlebars.runtime'
    moment: 'vendor/moment'
    'moment-locale': 'vendor/moment-locale'

define ['jquery', 'app'], ($, App) ->
  $ -> App.start()
