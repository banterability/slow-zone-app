module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        files:
          'public/nearby.js': 'lib/frontend/coffee/nearby.coffee'
        options:
          sourceMap: true
    stylus:
      compile:
        files:
          'public/style.css': 'lib/frontend/stylus/index.styl'
    watch:
      scripts:
        files: [
          'lib/frontend/stylus/*.styl'
          'lib/frontend/coffee/*.coffee'
        ]
        tasks: 'default'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['stylus', 'coffee']
