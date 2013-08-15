express = require 'express'
async = require 'async'
url = require 'url'
{sortBy, chain} = require 'underscore'

Client = require './lib/client'
parser = require './lib/parser'
{drawIcon} = require './lib/icons'


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


## Server

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"


## Helpers

getAllIncludedLines = (predictions) ->
  chain(predictions.map (predictionSet) ->
    predictionSet.trains.map (t) ->
      t.train.line.name
  ).flatten().uniq().value()

parsePredictions = (results) ->
  parser.fromServer(results)

prepareStop = (results, name) ->
  predictions = parser.fromServer results
  upcoming = presentUpcoming predictions

  {
    heading: name
    trains: predictions
    upcoming: upcoming
  }

presentUpcoming = (predictions) ->
  predictionList = predictions.map (train) -> "#{train.prediction.minutes}m"
  predictionList.join ", "

respondWithOptions = (err, results, res) ->
  predictions = for line of results
    prepareStop results[line], line

  lines = getAllIncludedLines predictions
  res.locals.icon = drawIcon lines

  predictions = sortBy predictions, (stop) ->
    nextTrain = stop.upcoming.split(",")[0]
    parseInt nextTrain, 10
  res.locals.predictions = predictions

  res.render 'options'
