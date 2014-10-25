{iconForPredictionSet} = require './presenters/icon'

createHeader = (results) ->
  train = results[0]
  "#{train.route.name} ##{train.route.run} towards #{train.destination.name}"

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
      res.locals.header = createHeader results
      res.render 'follow'
