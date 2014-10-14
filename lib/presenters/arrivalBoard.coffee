async = require 'async'
CtaApi = require '../api'
Schedule = require './schedule'
{chain, isArray, map} = require 'underscore'

module.exports = (app) ->

  client = new CtaApi apiKey: app.get 'apiKey'

  class ArrivalBoard
    constructor: (@routes) ->
      @routes = [@routes] unless isArray @routes

    arrivalsForStop: (stopId, options = {}) ->
      (callback) ->
        client.arrivals.byStop stopId, options, (err, data) ->
          callback err, new Schedule(data.eta).toHash()

    fetch: (callback) ->
      requests = map @routes, (route) =>
        @arrivalsForStop route.stopId, route.options

      async.parallel requests, (err, results) ->
        unifiedList = chain(results).flatten().sortBy(
          (result) -> result.prediction.arrivalTime
        ).value()
        callback err, unifiedList

  {ArrivalBoard}
