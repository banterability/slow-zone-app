{extend} = require 'underscore'
request = require 'request'
xml2js = require 'xml2js'

xmlParser = new xml2js.Parser explicitArray: false

class TrainTracker
  constructor: (options) ->
    @baseUrl = 'http://lapi.transitchicago.com/api/1.0'
    @apiKey = options.apiKey
    @registerEndpoints 'arrivals'

  registerEndpoints: (namespace) ->
    endpoint = require("./endpoints/#{namespace}")(this)
    extend this, endpoint

  fetch: (endpoint, queryParams, callback) ->
    defaultQueryParams =
      key: @apiKey

    apiOptions =
      qs: extend {}, queryParams, defaultQueryParams
      uri: "#{@baseUrl}/#{endpoint}"

    request apiOptions, (err, res, body) ->
      return callback err if err?
      # TODO: handle native errors
      xmlParser.parseString body, (err, result) ->
        callback err, result

module.exports = TrainTracker

