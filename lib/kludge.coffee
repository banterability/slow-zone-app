# Gunk extracted from index.coffee. To be further refactored in the future.
{chain, flatten, sortBy} = require 'underscore'
Client = require './client'
parser = require './parser'
{drawIcon} = require './icons'

module.exports = (app) ->
  client = new Client apiKey: app.get('apiKey')

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

  return {predictionsForStop, respondWithOptions}
