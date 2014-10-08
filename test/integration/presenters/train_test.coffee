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

    it 'extracts the route ID', ->
      assert.equal 'Org', @train.route.id

    it 'extracts the human-readable route name', ->
      assert.equal 'Orange', @train.route.name
