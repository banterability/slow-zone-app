async = require 'async'
CtaApi = require '../api'
Train = require './train'
{chain, isArray, map} = require 'underscore'

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
          callback err, createPredictions data.eta

    arrivalsForStop: (stopId, options = {}) ->
      (callback) ->
        client.arrivals.byStop stopId, options, (err, data) ->
          callback err, createPredictions data.eta

    fetch: (callback) ->
      requests = map @routes, (route) =>
        @arrivalsForStop route.stopId, route.options

      async.parallel requests, (err, results) ->
        unifiedList = chain(results).flatten().sortBy(
          (result) -> result.prediction.arrivalTime
        ).value()
        callback err, unifiedList

  {ArrivalBoard}
