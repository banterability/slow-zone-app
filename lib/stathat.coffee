StatHat = require 'stathat'

class Stats
  constructor: ->
    StatHat.useHTTPS = true
    @ezKey = process.env.STATHAT_EZ_KEY

  logCount: (key, value = 1) ->
    StatHat.trackEZCount @ezKey, key, value, (status, json) ->
      console.log "[StatHat] log to " + key, status, json.toString()

module.exports = new Stats()
