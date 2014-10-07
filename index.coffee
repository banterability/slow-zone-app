async = require 'async'
express = require 'express'
morgan = require 'morgan'

app = express()

app.set 'view engine', 'mustache'
app.set 'layout', 'layout'
app.engine 'mustache', require 'hogan-express'
app.enable 'view cache' if app.settings.env is "production"

app.use morgan('short')
app.use "/assets", express.static "#{__dirname}/public"
app.use require './lib/middleware/base_url'

throw "CTA API Key not configured! ($CTA_API_KEY)" unless process.env.CTA_API_KEY
app.set 'apiKey', process.env.CTA_API_KEY

kludge = require('./lib/kludge')(app)

app.get '/am', (req, res) ->
  requests = [
    kludge.predictionsForStop 30031, {rt: 'P'}
    kludge.predictionsForStop 30030, {rt: 'Brn'}
    kludge.predictionsForStop 30261
  ]

  async.parallel requests, (err, results) ->
    kludge.respondWithOptions err, results, res, templateName: kludge.getTemplate(req)

app.get '/pm', (req, res) ->
  requests = [
    kludge.predictionsForStop 30138
  ]

  async.parallel requests, (err, results) ->
    kludge.respondWithOptions err, results, res, templateName: kludge.getTemplate(req)

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"
