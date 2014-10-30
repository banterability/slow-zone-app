fs = require 'fs'
JSONStream = require 'JSONStream'
parseCsv = require 'csv-parse'
request = require 'request'
transform = require 'stream-transform'
unzip = require 'unzip'

GTFS_DATA_URL = "http://www.transitchicago.com/downloads/sch_data/google_transit.zip"


# Helpers
logProgress = (message, level) ->
  console.log "#{new Array(level).join('   ')}|_ #{message}…"

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
    # accessible: station.wheelchair_boarding == '1'
  }


# Set up stream components
requestData = request.get(GTFS_DATA_URL)
requestData.on 'response', -> console.log 'Downloading latest GTFS data…'

unzipFiles = unzip.Parse()
  .on 'entry', (entry) ->
    return entry.autodrain() unless entry.path == 'stops.txt'
    logProgress 'Unzipping stop data', 1
    entry.pipe(csvParser)

csvParser = parseCsv columns: true
  .on 'end', -> logProgress 'Parsing stop data', 2

STOPS = [] # Temporary array for holding parsed stop data
parseStationData = transform((record, callback) ->
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
  ).on 'end', -> logProgress 'Extracting train stations', 3

jsonWriter = JSONStream.stringify '{"stations":[', ',', ']}\n'
  .on 'end', -> logProgress 'Saving as JSON', 4

writeFile = fs.createWriteStream "data/stations-#{+(new Date)}.json"
  .on 'finish', ->
    console.log 'Done.'
    process.exit() # Just die


# Start the stream
csvParser.pipe(parseStationData).pipe(jsonWriter).pipe(writeFile)
requestData.pipe(unzipFiles)
