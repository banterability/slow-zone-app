{iconForPredictionSet} = require './presenters/icon'

module.exports =
  respondForStation: (res, arrivals) ->
    arrivals.fetch (err, results) ->
      res.locals.predictions = results
      res.locals.icon = iconForPredictionSet results
      res.render 'arrivals'

