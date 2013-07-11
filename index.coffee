express = require 'express'

Client = require './lib/client'
parser = require './lib/parser'

# Configuration

app = express()
app.set 'view engine', 'mustache'
app.set 'layout', 'layout'
# app.set 'partials', head: 'head'
app.engine 'mustache', require 'hogan-express'

app.use "/assets", express.static "#{__dirname}/public"
app.use express.bodyParser()

throw "CTA API Key not configured! ($CTA_API_KEY)" unless process.env.CTA_API_KEY
app.set 'apiKey', process.env.CTA_API_KEY

if app.settings.env is "production"
  app.enable 'view cache'

# Routes

app.get "/", (req, res) ->
  res.render 'index'

app.get "/stop/:stopId", (req, res) ->
  res.set "Content-Type", "text/html"

  client = new Client {apiKey: app.get('apiKey')}
  client.getStopPredictions req.params.stopId, (results) ->
    predictions = parser.fromServer(results)
    route = predictions[0].prediction.stop.name
    res.locals.predictions = predictions
    res.locals.route = route
    res.render 'results', partials: {prediction: "_prediction"}

app.get "/station/:stationId", (req, res) ->
  res.set "Content-Type", "text/html"

  client = new Client {apiKey: app.get('apiKey')}
  client.getStationPredictions req.params.stationId, (results) ->
    predictions = parser.fromServer(results)
    route = predictions[0].prediction.stop.name
    res.locals.predictions = predictions
    res.locals.route = route
    res.render 'results', partials: {prediction: "_prediction"}

port = process.env.PORT || 5000
app.listen port, ->
  console.log "Server up on port #{port}"