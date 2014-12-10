SlowZone = require 'slow-zone'

module.exports = (app) ->

  client = new SlowZone apiKey: app.get 'apiKey'

  class Schedule
    constructor: (@runNumber, @options = {}) ->

    fetch: (callback) ->
      client.follow.train @runNumber, callback

  {Schedule}
