fs = require 'fs'
csv = require 'csv'

stations = []

csv()
  .from.path("#{__dirname}/stops.csv")
  .on('record', (row) ->
    stations.push new Stop(row).toJSON()
  )
  .on('end', ->
    fs.writeFile("#{__dirname}/stops.json", JSON.stringify(stations), (err) ->
      console.log "ok"
    )
  )

class Stop
  constructor: (stopData) ->
    [@id, @direction, @name, longitude, latitude, stationName, stationDescription, stationId, stopCode, @isAccessible, red, blue, brown, green, purple, pexp, yellow, pink, orange] = stopData
    @lines = presentLines {red, blue, brown, green, purple, pexp, yellow, pink, orange}
    @coordinates = {latitude, longitude}
    @station =
      id: stationId
      name: stationName
      description: stationDescription

  toJSON: ->
    {@id, @direction, @name, @isAccessible, @lines, @coordinates, @station}


presentLines = (lineData) ->
  lines = {}
  for name, bool of lineData
    lines[name] = bool is '1'
  lines
