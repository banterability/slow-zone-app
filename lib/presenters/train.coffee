Dateline = require 'dateline'

# Attributes that don't need any processing can be mapped directly.
ATTRIBUTE_MAPPING =
  'destNm'  : 'destinationName'
  'destSt'  : 'destinationId'
  'heading' : 'locationHeading'
  'lat'     : 'locationLatitude'
  'lon'     : 'locationLongitude'
  'rn'      : 'runNumber'
  'rt'      : 'routeId'
  'staId'   : 'stationId'
  'staNm'   : 'stationName'
  'stpDe'   : 'stopDescription'
  'stpId'   : 'stopId'
  'prdt'    : 'predictionGenerationDatetime'
  'arrT'    : 'predictedArrivalDatetime'


class Train
  constructor: (attributes={}) ->
    (@[value] = attributes[key] if attributes[key]) for key, value of ATTRIBUTE_MAPPING

  route: ->
    switch route = @routeId
      when "Brn" then "Brown"
      when "G" then "Green"
      when "Org" then "Orange"
      when "P" then "Purple"
      when "Y" then "Yellow"
      else route

  arrivalTime: ->
    getNativeDate @predictedArrivalDatetime

  arrivalString: ->
    Dateline(@arrivalTime()).getAPTime()

  predictionTime: ->
    getNativeDate @predictionGenerationDatetime

  arrivalMinutes: ->
    Math.round (@arrivalTime() - @predictionTime()) / (60 * 1000)

  toHash: ->
    destination:
      id: @destinationId
      name: @destinationName
    location:
      lat: @locationLatitude
      lng: @locationLongitude
      heading: @locationHeading
    prediction:
      arrivalMinutes: @arrivalMinutes()
      arrivalString: @arrivalString()
      arrivalTime: @arrivalTime()
      predictionTime: @predictionTime()
    route:
      id: @routeId
      name: @route()
    run: @runNumber
    stop:
      id: @stopId
      description: @stopDescription
    station:
      id: @stationId
      name: @stationName

module.exports = Train

getNativeDate = (timeString) ->
  [str, year, month, day, hour, min, sec] = timeString.match /(\d{4})(\d{2})(\d{2}) (\d{2}):(\d{2}):(\d{2})/
  new Date year, month-1, day, hour, min, sec
