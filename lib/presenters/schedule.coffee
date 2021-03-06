SlowZone = require 'slow-zone'
StatHatLogger = require '../stathat'

client = new SlowZone apiKey: process.env.CTA_API_KEY

class Schedule
  constructor: (@runNumber) ->

  fetch: (callback) ->
    StatHatLogger.logCount 'api call'
    client.follow.train @runNumber, (err, body) ->
      if body?.length > 0
        callback err, body.map (train, index) ->
          train.index = index
          train
      else
        callback err, body

module.exports = {Schedule}
