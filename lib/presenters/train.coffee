Dateline = require 'dateline'

STRING_FIELDS =
  'destNm'  : 'destinationName'
  'rt'      : 'routeId'
  'staNm'   : 'stationName'
  'stpDe'   : 'stopDescription'

class Train
  constructor: (@attributes = {}) ->
    # Map string fields that don't need additional processing
    for attributeName, methodName of STRING_FIELDS
      @[methodName] = ((value) ->-> value)(@attributes[attributeName])

  ## Boolean Fields
  isApproaching: -> getNativeBoolean @attributes.isApp
  isDelayed:     -> getNativeBoolean @attributes.isDly
  isFaulty:      -> getNativeBoolean @attributes.isFlt
  isScheduled:   -> getNativeBoolean @attributes.isSch

  ## Date Fields
  arrivalTime:    -> getNativeDate @attributes.arrT
  predictionTime: -> getNativeDate @attributes.prdt

  ## Floating Point Fields
  latitude:  -> getNativeFloat @attributes.lat
  longitude: -> getNativeFloat @attributes.lon

  ## Generated Fields
  arrivalMinutes: ->
    Math.round (@arrivalTime() - @predictionTime()) / (60 * 1000)

  arrivalString:  -> Dateline(@arrivalTime()).getAPTime()

  route: ->
    switch route = @routeId()
      when "Brn" then "Brown"
      when "G" then "Green"
      when "Org" then "Orange"
      when "P" then "Purple"
      when "Y" then "Yellow"
      else route

  routeClass: ->
    @route().toLowerCase()

  ## Integer Fields
  destinationId: -> getNativeInteger @attributes.destSt
  directionId:   -> getNativeInteger @attributes.trDr
  heading:       -> getNativeInteger @attributes.heading
  runNumber:     -> getNativeInteger @attributes.rn
  stationId:     -> getNativeInteger @attributes.staId
  stopId:        -> getNativeInteger @attributes.stpId

  toHash: ->
    destination:
      id: @destinationId()
      name: @destinationName()
    location:
      latitude: @latitude()
      longitude: @longitude()
      heading: @heading()
    prediction:
      arrivalMinutes: @arrivalMinutes()
      arrivalString: @arrivalString()
      arrivalTime: @arrivalTime()
      predictionTime: @predictionTime()
    route:
      class: @routeClass()
      directionId: @directionId()
      id: @routeId()
      name: @route()
      run: @runNumber()
    station:
      id: @stationId()
      name: @stationName()
      stop:
        id: @stopId()
        description: @stopDescription()
    status:
      approaching: @isApproaching()
      delayed: @isDelayed()
      faulty: @isFaulty()
      scheduled: @isScheduled()

module.exports = Train

## Helpers

getNativeBoolean = (booleanString) ->
  getNativeInteger(booleanString) == 1

getNativeDate = (timeString) ->
  [str, year, month, day, hour, min, sec] = timeString.match /(\d{4})(\d{2})(\d{2}) (\d{2}):(\d{2}):(\d{2})/
  new Date year, month-1, day, hour, min, sec

getNativeFloat = (floatString) ->
  parseFloat floatString

getNativeInteger = (integerString) ->
  parseInt integerString, 10
