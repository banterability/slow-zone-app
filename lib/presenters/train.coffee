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

  toHash: ->
    destination:
      id: @destinationId
      name: @destinationName
    location:
      lat: @locationLatitude
      lng: @locationLongitude
      heading: @locationHeading
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
