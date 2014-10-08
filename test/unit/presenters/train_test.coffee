assert = require 'assertive'
bond = require 'bondjs'
Train = require '../../../lib/presenters/train'

describe 'Train', ->
  describe 'route', ->
    describe 'sets friendly name for abbreviated routes', ->
      it 'handles the Brown line', ->
        t = new Train
        bond(t, 'routeId').return('Brn')
        assert.equal 'Brown', t.route()

      it 'handles the Green line', ->
        t = new Train
        bond(t, 'routeId').return('G')
        assert.equal 'Green', t.route()

      it 'handles the Orange line', ->
        t = new Train
        bond(t, 'routeId').return('Org')
        assert.equal 'Orange', t.route()

      it 'handles the Purple line', ->
        t = new Train
        bond(t, 'routeId').return('P')
        assert.equal 'Purple', t.route()

      it 'handles the Yellow line', ->
        t = new Train
        bond(t, 'routeId').return('Y')
        assert.equal 'Yellow', t.route()

    describe 'passes through unabbreviated routes', ->
      it 'handles the Red line', ->
        t = new Train
        bond(t, 'routeId').return('Red')
        assert.equal 'Red', t.route()

      it 'handles the Blue line', ->
        t = new Train
        bond(t, 'routeId').return('Blue')
        assert.equal 'Blue', t.route()

      it 'handles the Pink line', ->
        t = new Train
        bond(t, 'routeId').return('Pink')
        assert.equal 'Pink', t.route()
