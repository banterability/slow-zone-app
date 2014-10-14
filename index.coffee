express = require 'express'
morgan = require 'morgan'
respondWithPredictions = require './lib/responders'

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

{ArrivalBoard} = require('./lib/presenters/arrivalBoard')(app)


app.get '/stop/:stopId', (req, res) ->
  stopId = req.params['stopId']
  arrivals = new ArrivalBoard {stopId}

  respondWithPredictions res, arrivals

app.get '/am', (req, res) ->
  arrivals = new ArrivalBoard [
    {stopId: 30031, options: {rt: 'P'}}
    {stopId: 30030, options: {rt: 'Brn'}}
    {stopId: 30261}
  ]

  respondWithPredictions res, arrivals

app.get '/pm', (req, res) ->
  arrivals = new ArrivalBoard [
    {stopId: 30138}
  ]

  respondWithPredictions res, arrivals

port = process.env.PORT || 5678
app.listen port, ->
  console.log "Server up on port #{port}"
