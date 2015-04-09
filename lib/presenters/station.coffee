{extend, find, map, isArray} = require 'underscore'
fs = require 'fs'
geolib = require 'geolib'

# Built once at startup and remain in memory; FIXME someday
STATION_METADATA = JSON.parse(fs.readFileSync('./data/stations.json', encoding: 'utf-8')).stations
STATION_COORDINATES = {}

for station in STATION_METADATA
  STATION_COORDINATES[station.id] = {latitude: station.latitude, longitude: station.longitude}

presentDistance = (meters) ->
  feet: geolib.convertUnit 'ft', meters
  miles: geolib.convertUnit 'mi', meters

nearbyStations = (coordinates, limit=1) ->
  nearest = geolib.findNearest coordinates, STATION_COORDINATES, 0, limit
  nearest = [nearest] unless isArray nearest

  index = -1

  map nearest, (nearbyStation) ->
    index += 1
    stationData = find STATION_METADATA, (station) -> station.id == nearbyStation.key
    extend {}, stationData, index: index, distance: presentDistance nearbyStation.distance

module.exports = {nearbyStations}
