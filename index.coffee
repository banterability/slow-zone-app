async = require 'async'
baseUrlMiddleware = require './lib/middleware/base_url'
Client = require './lib/client'
express = require 'express'
hogan = require 'hogan-express'
morgan = require 'morgan'
parser = require './lib/parser'
{drawIcon} = require './lib/icons'
{flatten} = require 'underscore'
{sortBy, chain} = require 'underscore'

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

client = new Client apiKey: app.get('apiKey')

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

getTemplate = (req) ->
  return 'new_options' if req.query['new']
  'options'

getAllIncludedLines = (predictions) ->
  chain(predictions.map (predictionSet) ->
    predictionSet.map (t) ->
      t.train.line.name
    ).flatten().uniq().value()

predictionsForStop = (stopId, options = {}) ->
  return (callback) ->
    client.getStopPredictions stopId, options, (results) ->
      callback(null, results)

respondWithOptions = (err, results, res, options = {}) ->
  predictions = for response in results
    parser.fromServer response

  res.locals.icon = drawIcon getAllIncludedLines(predictions)

  res.locals.predictions = chain(predictions).flatten().sortBy(
    (train) -> parseInt train.prediction.minutes
  ).value()

  res.render options.templateName
