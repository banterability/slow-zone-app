SlowZone = require 'slow-zone'
StatHatLogger = require '../stathat'

module.exports = (app) ->

  client = new SlowZone apiKey: app.get 'apiKey'

  class Schedule
    constructor: (@runNumber) ->

    fetch: (callback) ->
      StatHatLogger.logCount 'api call'
      client.follow.train @runNumber, (err, body) ->
        if body?.length > 0
          index = 0
          callback err, body.map (train) ->
            train.index = index
            index += 1
            train
        else
          callback err, body

  {Schedule}
