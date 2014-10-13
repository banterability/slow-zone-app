async = require 'async'
CtaApi = require '../api'
Schedule = require './schedule'
{map} = require 'underscore'

module.exports = (app) ->

  client = new CtaApi apiKey: app.get 'apiKey'

  class ArrivalBoard
    constructor: (@routes) ->

    arrivalsForStop: (stopId, options = {}) ->
      (callback) ->
        client.arrivals.byStop stopId, {}, (err, data) ->
          callback err, new Schedule(data.eta).toHash()

    fetch: (callback) ->
      requests = map @routes, (route) =>
        @arrivalsForStop route.stopId, route.options

      async.parallel requests, callback

  {ArrivalBoard}
