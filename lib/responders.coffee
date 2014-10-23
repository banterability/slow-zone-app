{iconForPredictionSet} = require './presenters/icon'

module.exports =
  respondForStation: (res, arrivals) ->
    arrivals.fetch (err, results) ->
      res.locals.predictions = results
      res.locals.icon = iconForPredictionSet results
      res.render 'arrivals'

  respondForTrain: (res, schedule) ->
    schedule.fetch (err, results) ->
      res.locals.schedule = results
      res.render 'follow'
