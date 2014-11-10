{iconForPredictionSet} = require './presenters/icon'

createHeader = (results, type) ->
  train = results[0]
  switch type
    when 'route'
      head: "#{train.route.name} ##{train.route.run} towards #{train.destination.name}"
    when 'station'
      head: "Arrivals for #{train.station.name}"
    when 'stop'
      head: "Arrivals for #{train.station.name}"
      subhead: "#{train.station.stop.description}"

respondWithError = (res, errorMessage) ->
  res.locals.message = errorMessage
  res.render 'error'

module.exports =
  respondForStation: (res, arrivals, options = {}) ->
    arrivals.fetch (err, results) ->
      return respondWithError res, err.toString() if err
      res.locals.predictions = results
      res.locals.icon = iconForPredictionSet results
      res.locals.title = createHeader results, options.headerType if options.headerType?
      res.render 'arrivals'

  respondForTrain: (res, schedule) ->
    schedule.fetch (err, results) ->
      return respondWithError res, err.toString() if err
      res.locals.schedule = results
      res.locals.title = createHeader results, 'route'
      res.render 'follow'
