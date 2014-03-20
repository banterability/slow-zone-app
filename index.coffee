express = require 'express'
async = require 'async'
url = require 'url'
{sortBy, chain} = require 'underscore'
{flatten} = require 'underscore'

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

predictionsForStop = (stopId, options = {}) ->
  return (callback) ->
    client.getStopPredictions stopId, options, (results) ->
      callback(null, results)

getTemplate = (req) ->
  return 'new_options' if req.query['new']
  'options'

app.get '/am', (req, res) ->
  requests = [
    predictionsForStop 30031, {rt: 'P'}
    predictionsForStop 30030, {rt: 'Brn'}
    predictionsForStop 30261
  ]

  async.parallel requests, (err, results) ->
    respondWithOptions err, results, res, templateName: getTemplate(req)


app.get '/pm', (req, res) ->
  requests = [
    predictionsForStop 30138
  ]

  async.parallel requests, (err, results) ->
    respondWithOptions err, results, res, templateName: getTemplate(req)


## Server

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"


## Helpers

getAllIncludedLines = (predictions) ->
  chain(predictions.map (predictionSet) ->
    console.log predictionSet
    predictionSet.map (t) ->
      t.train.line.name
    ).flatten().uniq().value()

respondWithOptions = (err, results, res, options = {}) ->
  predictions = for response in results
    parser.fromServer response

  res.locals.icon = drawIcon getAllIncludedLines(predictions)

  res.locals.predictions = chain(predictions).flatten().sortBy(
    (train) -> parseInt train.prediction.minutes
  ).value()

  res.render options.templateName
