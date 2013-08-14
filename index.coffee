express = require 'express'
async = require 'async'
url = require 'url'
{sortBy} = require 'underscore'

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

client = new Client apiKey: app.get('apiKey')

# Middleware

# Add `baseUrl` to all requests
app.use (req, res, next) ->
  res.locals.baseUrl = url.format
    host: req.headers.host
    protocol: req.protocol
  next()

# Routes

app.get '/am', (req, res) ->
  requests =
    Purple: (callback) ->
      client.getStopPredictions 30031, {rt: 'P'}, (results) ->
        callback(null, results)

    Blue: (callback) ->
      client.getStopPredictions 30261, {rt: 'Blue'}, (results) ->
        callback(null, results)

  async.parallel requests, (err, results) ->
    respondWithOptions err, results, res


app.get '/pm', (req, res) ->
  requests =
    Brown: (callback) ->
      client.getStopPredictions 30138, {rt: 'Brn'}, (results) ->
        callback(null, results)

    Purple: (callback) ->
      client.getStopPredictions 30138, {rt: 'P'}, (results) ->
        callback(null, results)

  async.parallel requests, (err, results) ->
    respondWithOptions err, results, res


port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"

respondWithOptions = (err, results, res) ->
  predictions = for line of results
    prepareStop results[line], line

  predictions = sortBy predictions, (stop) ->
    nextTrain = stop.upcoming.split(",")[0]
    parseInt nextTrain, 10

  res.locals.predictions = predictions
  res.render 'options'

parsePredictions = (results) ->
  parser.fromServer(results)

prepareStop = (results, name) ->
  predictions = parser.fromServer results
  upcoming = presentUpcoming predictions
  first = predictions.shift()

  {
    heading: name
    next: first
    future: predictions
    upcoming: upcoming
  }

presentUpcoming = (predictions) ->
  predictionList = predictions.map (train) -> "#{train.prediction.minutes}m"
  predictionList.join ", "

renderPredictions = (results, res, cb) ->
  predictions = parsePredictions(results)
  console.log "Found #{predictions.length} trains."
  route = predictions[0].prediction.stop.name
  res.locals.predictions = predictions
  res.locals.route = route
  cb(res)

renderForWeb = (res) ->
  res.render 'results', partials: {prediction: "_prediction"}

renderForPrinter = (res) ->
  res.render 'printout'
