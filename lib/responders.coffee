{iconForPredictionSet} = require './presenters/icon'

module.exports = respondWithPredictions = (res, arrivalBoard) ->
  arrivalBoard.fetch (err, results) ->
    res.locals.predictions = results
    res.locals.icon = iconForPredictionSet results
    res.render 'options'
