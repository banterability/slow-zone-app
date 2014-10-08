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
