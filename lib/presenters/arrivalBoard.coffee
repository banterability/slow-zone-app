async = require 'async'
{chain, isArray, map} = require 'underscore'
SlowZone = require 'slow-zone'

module.exports = (app) ->

  client = new SlowZone apiKey: app.get 'apiKey'

  class ArrivalBoard
    constructor: (@routes) ->
      @routes = [@routes] unless isArray @routes

    arrivalsForStation: (stationId, options = {}) ->
      (callback) ->
        client.arrivals.byStation stationId, options, callback

    arrivalsForStop: (stopId, options = {}) ->
      (callback) ->
        client.arrivals.byStop stopId, options, callback

    fetch: (callback) ->
      requests = map @routes, (route) =>
        if route.stopId
          @arrivalsForStop route.stopId, route.options
        else if route.stationId
          @arrivalsForStation route.stationId, route.options

      async.parallel requests, (err, results) ->
        return callback err, null if err
        unifiedList = chain(results).flatten().sortBy(
          (result) -> result.prediction.arrivalTime
        ).value()
        callback null, unifiedList

  {ArrivalBoard}
