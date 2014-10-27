CtaApi = require '../api'
Train = require './train'

module.exports = (app) ->

  client = new CtaApi apiKey: app.get 'apiKey'

  createSchedule = (scheduleData = [], options = {}) ->
    (new Train(trainData, options).toHash() for trainData in scheduleData)

  class Schedule
    constructor: (@runNumber, @options = {}) ->

    fetch: (callback) ->
      client.follow.train @runNumber, (err, data) =>
        callback err, createSchedule data?.eta, @options

  {Schedule}
