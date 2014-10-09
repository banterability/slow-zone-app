assert = require 'assertive'
Train = require '../../../lib/presenters/train'
{loadJSONMock} = require '../../helpers'

mockTrain = loadJSONMock 'train.json'

describe 'Train', ->
  it 'exists', ->
    assert.truthy Train

  describe "given a train's attributes", ->
    before ->
      @train = new Train(mockTrain).toHash()

    describe 'destination station (headsign)', ->
      it 'presents the destination station ID', ->
        assert.equal 30182, @train.destination.id

      it 'presents the destination station name', ->
        assert.equal 'Midway', @train.destination.name

    describe 'prediction station (this stop)', ->
      it 'presents the prediction station ID', ->
        assert.equal 40160, @train.station.id

      it 'presents the prediction station name', ->
        assert.equal 'LaSalle/Van Buren', @train.station.name

      it 'presents the prediction stop ID', ->
        assert.equal 30031, @train.stop.id

      it 'presents the prediction stop description', ->
        assert.equal 'Service at Inner Loop platform', @train.stop.description

    describe 'route (line)', ->
      it 'presents the route ID', ->
        assert.equal 'Org', @train.route.id

      it 'presents the human-readable route name', ->
        assert.equal 'Orange', @train.route.name

    it 'presents the run number', ->
      assert.equal 715, @train.run

    describe 'flags', ->
      it 'presents whether the train is approaching', ->
        assert.truthy @train.flags.approaching

      it 'presents whether the train is delayed', ->
        assert.falsey @train.flags.delayed

      it 'presents whether the train is faulty', ->
        assert.falsey @train.flags.faulty

      it 'presents whether the train is scheduled', ->
        assert.falsey @train.flags.scheduled

    describe 'prediction', ->
      it 'presents the arrival time as a native JS date', ->
        expected = new Date(2014, 9, 7, 14, 50, 27).getTime()
        actual = @train.prediction.arrivalTime.getTime()
        assert.equal expected, actual

      it 'presents the arrival time as a human-readable string', ->
        assert.equal '2:50 p.m.', @train.prediction.arrivalString

      it 'presents the original prediction time as a native JS date', ->
        expected = new Date(2014, 9, 7, 14, 49, 27).getTime()
        actual = @train.prediction.predictionTime.getTime()
        assert.equal expected, actual

      it 'presents the number of minutes between the prediction time and the arrival time', ->
        assert.equal 1, @train.prediction.arrivalMinutes
