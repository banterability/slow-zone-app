CtaApi = require '../api'
Train = require './train'

module.exports = (app) ->

  client = new CtaApi apiKey: app.get 'apiKey'

  createSchedule = (scheduleData) ->
    (new Train(trainData).toHash() for trainData in scheduleData)

  class Schedule
    constructor: (@runNumber) ->

    fetch: (callback) ->
      client.follow.train @runNumber, (err, data) ->
        callback err, createSchedule data.eta

  {Schedule}
