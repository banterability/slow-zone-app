async = require 'async'
{chain, isArray, map} = require 'underscore'
SlowZone = require 'slow-zone'
StatHatLogger = require '../stathat'

client = new SlowZone apiKey: process.env.CTA_API_KEY

class ArrivalBoard
  constructor: (@routes) ->
    @routes = [@routes] unless isArray @routes

  arrivalsForStation: (stationId, options = {}) ->
    (callback) ->
      StatHatLogger.logCount 'api call'
      client.arrivals.byStation stationId, options, callback

  arrivalsForStop: (stopId, options = {}) ->
    (callback) ->
      StatHatLogger.logCount 'api call'
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

      index = 0
      unifiedList = unifiedList.map (result) ->
        result.index = index
        index += 1
        result

      callback null, unifiedList

module.exports = {ArrivalBoard}
