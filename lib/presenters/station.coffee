{extend, find, isArray} = require 'underscore'
fs = require 'fs'
geolib = require 'geolib'
StatHatLogger = require '../stathat'

# Built once at startup and remain in memory; FIXME someday
STATION_METADATA = JSON.parse(fs.readFileSync('./data/stations.json', encoding: 'utf-8')).stations
STATION_COORDINATES = {}

for station in STATION_METADATA
  STATION_COORDINATES[station.id] = {latitude: station.latitude, longitude: station.longitude}

presentDistance = (meters) ->
  feet: geolib.convertUnit 'ft', meters
  miles: geolib.convertUnit 'mi', meters

nearbyStations = (coordinates, limit=1) ->
  StatHatLogger.logCount 'find nearest'
  nearest = geolib.findNearest coordinates, STATION_COORDINATES, 0, limit
  nearest = [nearest] unless isArray nearest

  nearest.map (nearbyStation, index) ->
    stationData = find STATION_METADATA, (station) -> station.id == nearbyStation.key
    extend {}, stationData, index: index, distance: presentDistance nearbyStation.distance

module.exports = {nearbyStations}
