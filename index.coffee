baseUrlMiddleware = require './lib/middleware/base_url'
express = require 'express'
hogan = require 'hogan-express'
morgan = require 'morgan'
{respondForStation, respondForTrain} = require './lib/responders'

app = express()

app.set 'view engine', 'mustache'
app.set 'layout', 'layout'
app.engine 'mustache', hogan
app.enable 'view cache' if app.settings.env is "production"

app.use morgan('short')
app.use "/assets", express.static "#{__dirname}/public"
app.use baseUrlMiddleware

throw "CTA API Key not configured! ($CTA_API_KEY)" unless process.env.CTA_API_KEY
app.set 'apiKey', process.env.CTA_API_KEY

{ArrivalBoard} = require('./lib/presenters/arrivalBoard')(app)
{Schedule} = require('./lib/presenters/schedule')(app)

app.get '/stop/:stopId', (req, res) ->
  stopId = req.params.stopId
  arrivals = new ArrivalBoard {stopId}

  respondForStation res, arrivals

app.get '/station/:stationId', (req, res) ->
  stationId = req.params.stationId
  arrivals = new ArrivalBoard {stationId}

  respondForStation res, arrivals

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
  runSchedule = new Schedule runId, {highlightStop: req.query.stop}

  respondForTrain res, runSchedule

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"
