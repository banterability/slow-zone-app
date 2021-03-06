bodyParser = require 'body-parser'
express = require 'express'
hogan = require 'hogan-express'
morgan = require 'morgan'
raven = require 'raven'

{ArrivalBoard} = require './lib/presenters/arrivalBoard'
{drawIcon} = require './lib/presenters/icon'
{nearbyStations} = require './lib/presenters/station'
{respondForStation, respondForStatusBoard, respondForTrain} = require './lib/responders'
{Schedule} = require './lib/presenters/schedule'
StatHatLogger = require './lib/stathat'

app = express()

throw "CTA API Key not configured! ($CTA_API_KEY)" unless process.env.CTA_API_KEY
throw "StatHat EZ Key not configured! ($STATHAT_EZ_KEY)" unless process.env.STATHAT_EZ_KEY
throw "Sentry DSN not configured! ($SENTRY_DSN)" unless process.env.SENTRY_DSN

app.use raven.middleware.express.requestHandler(process.env.SENTRY_DSN)
app.use raven.middleware.express.errorHandler(process.env.SENTRY_DSN)
app.use bodyParser.json()
app.use morgan('short')

app.use (req, res, next) ->
  StatHatLogger.logCount 'request'
  next()

app.set 'view engine', 'mustache'
app.set 'partials', {'spinner'}
app.set 'layout', 'layout'
app.engine 'mustache', hogan

app.enable "trust proxy"

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

  res.locals.icon = drawIcon() # TODO: Customize this

  respondForTrain res, runSchedule

app.get '/nearby', (req, res) ->
  res.locals.scripts = [
    {url: '/vendor/jaxx.js'}
    {url: '/nearby.js'}
  ]
  res.locals.icon = drawIcon()
  res.locals.title = head: 'Nearby Stations'
  res.render 'nearby'

app.post '/locate', (req, res) ->
  unless req.body.lat and req.body.lng
    res.statusCode = 400
    res.send error: 'invalid request'

  results = nearbyStations {latitude: req.body.lat, longitude: req.body.lng}, 5
  res.send closestStations: results

app.get '/', (req, res) ->
  res.locals.icon = drawIcon() # TODO: Customize this
  res.render 'index'

if app.settings.env is "production"
  app.enable 'view cache'

else
  app.use express.static('public')

  app.get '/lib/frontend/coffee/:sourcefile', (req, res) ->
    fs = require 'fs'
    fs.createReadStream("#{__dirname}/lib/frontend/coffee/#{req.params.sourcefile}").pipe(res)

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"
