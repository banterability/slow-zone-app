geolib = require 'geolib'
units = require 'node-units'

stations = [
  {
    name: "Grand (Blue)"
    latitude: 41.891189
    longitude: -87.647578
    stationId: 40490
  }, {
    name: "Chicago (Brown)"
    latitude: 41.89681
    longitude: -87.635924
    stationId: 40710
  },
  {
    name: "LaSalle/Van Buren"
    latitude: 41.8768
    longitude: -87.631739
    stationId: 40160
  }
]

closestStation = (lat, lng) ->
  result = geolib.findNearest {latitude: lat, longitude: lng}, stations
  console.log result, stations[result.key]

closestStation 41.896613, -87.643130

distanceToStations = (lat, lng) ->
  result = geolib.orderByDistance {latitude: lat, longitude: lng}, stations

  console.log result

distanceToStations 41.896613, -87.643130