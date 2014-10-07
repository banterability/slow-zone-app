module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    stylus:
      compile:
        files:
          'public/style.css': ['lib/frontend/stylus/index.styl']
        ]
    watch:
      scripts:
        files: ['lib/frontend/stylus/*.styl']
        tasks: 'default'

  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['stylus']
