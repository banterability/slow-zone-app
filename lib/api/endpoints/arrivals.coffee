ENDPOINT = 'ttarrivals.aspx'

module.exports = (client) ->
  arrivals:
    byStop: (stopId, options = {}, callback) ->
      options.stpid = stopId
      client.fetch ENDPOINT, options, (err, data) ->
        callback err, data?.ctatt

    byStation: (stationId, options = {}, callback) ->
      options.mapid = stationId
      client.fetch ENDPOINT, options, (err, data) ->
        callback err, data?.ctatt
