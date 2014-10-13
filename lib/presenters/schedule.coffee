Train = require './train'

class Schedule
  constructor: (@trains = []) ->

  toHash: ->
    @trains.map (trainData) -> new Train(trainData).toHash()

module.exports = Schedule
