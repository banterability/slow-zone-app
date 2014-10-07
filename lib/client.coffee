request = require 'request'
{extend} = require 'underscore'

class Client
  BASE_URL = "http://lapi.transitchicago.com/api/1.0"

  constructor: (options={}) ->
    @apiKey = options.apiKey

  buildQueryString: (params) ->
    params.key = @apiKey
    ("#{key}=#{value}" for key, value of params).join("&")

  buildUrl: (endpoint, params={}) ->
    queryString = @buildQueryString params
    "#{BASE_URL}/#{endpoint}?#{queryString}"

  fetch: (options, callback) ->
    options.headers ?= {}
    options.headers['User-Agent'] = "Busted/pre-release"

    requestData =
      options: options
      start: new Date()

    request options, (error, response, body) ->
      callback body.toString()

  ## routes ##

  getStationPredictions: (stationId, options, callback) ->
    params = extend {}, {mapid: stationId}, options
    @getArrivals params, callback

  getStopPredictions: (stopId, options, callback) ->
    params = extend {}, {stpid: stopId}, options
    @getArrivals params, callback

  getArrivals: (params, callback) ->
    url = @buildUrl 'ttarrivals.aspx', params
    @fetch {url}, callback

module.exports = Client
