assert = require 'assertive'
bond = require 'bondjs'
Train = require '../../../lib/presenters/train'

trainWithStubbedProperty = (property, stub) ->
  t = new Train
  bond(t, property).to(stub)
  t

describe 'Train', ->
  describe 'route', ->
    describe 'sets friendly name for abbreviated routes', ->
      it 'handles the Brown line', ->
        t = trainWithStubbedProperty 'routeId', 'Brn'
        assert.equal 'Brown', t.route()

      it 'handles the Green line', ->
        t = trainWithStubbedProperty 'routeId', 'G'
        assert.equal 'Green', t.route()

      it 'handles the Orange line', ->
        t = trainWithStubbedProperty 'routeId', 'Org'
        assert.equal 'Orange', t.route()

      it 'handles the Purple line', ->
        t = trainWithStubbedProperty 'routeId', 'P'
        assert.equal 'Purple', t.route()

      it 'handles the Yellow line', ->
        t = trainWithStubbedProperty 'routeId', 'Y'
        assert.equal 'Yellow', t.route()

    describe 'passes through unabbreviated routes', ->
      it 'handles the Red line', ->
        t = trainWithStubbedProperty 'routeId', 'Red'
        assert.equal 'Red', t.route()

      it 'handles the Blue line', ->
        t = trainWithStubbedProperty 'routeId', 'Blue'
        assert.equal 'Blue', t.route()

      it 'handles the Pink line', ->
        t = trainWithStubbedProperty 'routeId', 'Pink'
        assert.equal 'Pink', t.route()
