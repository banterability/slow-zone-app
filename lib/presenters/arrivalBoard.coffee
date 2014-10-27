async = require 'async'
{chain, isArray, map} = require 'underscore'
CtaApi = require '../api'
Train = require './train'

module.exports = (app) ->

  client = new CtaApi apiKey: app.get 'apiKey'

  createPredictions = (predictionData = []) ->
    predictionData = [predictionData] unless isArray predictionData
    predictionData.map (trainData) -> new Train(trainData).toHash()

  class ArrivalBoard
    constructor: (@routes) ->
      @routes = [@routes] unless isArray @routes

    arrivalsForStation: (stationId, options = {}) ->
      (callback) ->
        client.arrivals.byStation stationId, options, (err, data) ->
          callback err, createPredictions data?.eta

    arrivalsForStop: (stopId, options = {}) ->
      (callback) ->
        client.arrivals.byStop stopId, options, (err, data) ->
          callback err, createPredictions data?.eta

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
