baseUrlMiddleware = require './lib/middleware/base_url'
bodyParser = require 'body-parser'
express = require 'express'
hogan = require 'hogan-express'
morgan = require 'morgan'
StatHatLogger = require './lib/stathat'
{drawIcon} = require './lib/presenters/icon'
{nearbyStations} = require './lib/presenters/station'
{respondForStation, respondForStatusBoard, respondForTrain} = require './lib/responders'

app = express()

throw "CTA API Key not configured! ($CTA_API_KEY)" unless process.env.CTA_API_KEY
app.set 'apiKey', process.env.CTA_API_KEY

{ArrivalBoard} = require('./lib/presenters/arrivalBoard')(app)
{Schedule} = require('./lib/presenters/schedule')(app)

app.use bodyParser.json()
app.use morgan('short')
app.use "/assets", express.static "#{__dirname}/public"
app.use baseUrlMiddleware
app.use (req, res, next) ->
  StatHatLogger.logCount 'request'
  next()

app.set 'view engine', 'mustache'
app.set 'partials', {'spinner'}
app.set 'layout', 'layout'
app.engine 'mustache', hogan
app.enable 'view cache' if app.settings.env is "production"

app.get '/stop/:stopId', (req, res) ->
  stopId = req.params.stopId
  arrivals = new ArrivalBoard {stopId}

  respondForStation res, arrivals, {headerType: 'stop'}

app.get '/station/:stationId', (req, res) ->
  stationId = req.params.stationId
  arrivals = new ArrivalBoard {stationId}

  respondForStation res, arrivals, {headerType: 'station'}

app.get '/statusboard/:stationId', (req, res) ->
  stationId = req.params.stationId
  arrivals = new ArrivalBoard {stationId}

  respondForStatusBoard res, arrivals, {headerType: 'station'}

app.get '/am', (req, res) ->
  arrivals = new ArrivalBoard [
    {stopId: 30031, options: {rt: 'P'}}
    {stopId: 30030, options: {rt: 'Brn'}}
    {stopId: 30261}
  ]

  respondForStation res, arrivals

app.get '/pm', (req, res) ->
  arrivals = new ArrivalBoard [
    {stopId: 30138}
  ]

  respondForStation res, arrivals

app.get '/follow/:run', (req, res) ->
  runId = req.params.run
  runSchedule = new Schedule runId

  respondForTrain res, runSchedule

app.get '/nearby', (req, res) ->
  res.locals.scripts = [
    {url: '/assets/vendor/jaxx.js'}
    {url: '/assets/nearby.js'}
  ]
  res.locals.icon = drawIcon()
  res.locals.title = head: 'Nearby Stations'
  res.render 'nearby'

app.post '/locate', (req, res) ->
  unless req.body.lat and req.body.lng
    res.statusCode = 400
    res.send error: 'invalid request'

  results = nearbyStations {latitude: req.body.lat, longitude: req.body.lng}, 3
  res.send closestStations: results

unless app.settings.env is "production"
  app.get '/lib/frontend/coffee/:sourcefile', (req, res) ->
    fs = require 'fs'
    fs.createReadStream("#{__dirname}/lib/frontend/coffee/#{req.params.sourcefile}").pipe(res)

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"
