request = require 'request'

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

  getStationPredictions: (stationId, callback) ->
    @getArrivals {mapid: stationId}, callback

  getStopPredictions: (stopId, callback) ->
    @getArrivals {stpid: stopId}, callback

  getArrivals: (params, callback) ->
    url = @buildUrl 'ttarrivals.aspx', params
    console.log "Requesting #{url}..."
    @fetch {url}, callback

module.exports = Client
