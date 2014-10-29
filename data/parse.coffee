fs = require 'fs'
JSONStream = require 'JSONStream'
parse = require 'csv-parse'
request = require 'request'
transform = require 'stream-transform'
unzip = require 'unzip'


# Helpers
presentStop = (stop) ->
  stop.stop_id

presentStation = (station, stops) ->
  availableStops = STOPS[station.stop_id]
  return {
    id: station.stop_id
    name: station.stop_name
    stops: availableStops
    latitude: station.stop_lat
    longitude: station.stop_lon
    accessible: station.wheelchair_boarding == '1'
  }


# Set up stream components
zipFile = fs.createReadStream 'google_transit.zip'

csvParser = parse
  columns: true
  delimiter: ','

STOPS = [] # Temporary array for holding parsed stop data

parseStationData = transform (record, callback) ->
  if record.stop_code
    # discared bus stops
    callback null, null
  else if record.location_type == '0'
    # make a note of stops, but don't return anything
    STOPS[record.parent_station] = STOPS[record.parent_station] || []
    STOPS[record.parent_station].push presentStop(record)
    callback null, null
  else
    # re-associate stops with their parent station
    callback null, presentStation record

jsonWriter = JSONStream.stringify '{\n"stations":[\n', ',\n', '\n]\n}\n'

writeFile = fs.createWriteStream "stations-#{+(new Date)}.json"


# Start the stream
zipFile
  .pipe(unzip.Parse())
  .on 'entry', (entry) ->
    if entry.path is 'stops.txt'
      entry
        .pipe(csvParser)
        .pipe(parseStationData)
        .pipe(jsonWriter)
        .pipe(writeFile)
    else
      entry.autodrain()
