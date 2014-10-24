{iconForPredictionSet} = require './presenters/icon'

respondWithError = (res, errorMessage) ->
  res.locals.message = errorMessage
  res.render 'error'

module.exports =
  respondForStation: (res, arrivals) ->
    arrivals.fetch (err, results) ->
      return respondWithError res, err.toString() if err
      res.locals.predictions = results
      res.locals.icon = iconForPredictionSet results
      res.render 'arrivals'

  respondForTrain: (res, schedule) ->
    schedule.fetch (err, results) ->
      return respondWithError res, err.toString() if err
      res.locals.schedule = results
      res.render 'follow'
