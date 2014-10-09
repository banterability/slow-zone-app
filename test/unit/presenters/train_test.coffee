assert = require 'assertive'
bond = require 'bondjs'
Dateline = require 'dateline'
Train = require '../../../lib/presenters/train'

trainWithAttributes = (attributes) ->
  t = new Train attributes

trainWithStubbedMethod = ([stubbedMethods]) ->
  t = new Train
  for method, returnValue of stubbedMethods
    bond(t, method).return(returnValue)
  t

describe 'Train', ->
  describe 'boolean fields', ->
    describe 'isApproaching', ->
      it 'returns true if train is approaching', ->
        t = trainWithAttributes isApp: '1'
        assert.truthy t.isApproaching()

      it 'returns false if train is not approaching', ->
        t = trainWithAttributes isApp: '0'
        assert.falsey t.isApproaching()

    describe 'isDelayed', ->
      it 'returns true if train is delayed', ->
        t = trainWithAttributes isDly: '1'
        assert.truthy t.isDelayed()

      it 'returns false if train is not delayed', ->
        t = trainWithAttributes isDly: '0'
        assert.falsey t.isDelayed()

    describe 'isFaulty', ->
      it 'returns true if train is faulty', ->
        t = trainWithAttributes isFlt: '1'
        assert.truthy t.isFaulty()

      it 'returns false if train is not faulty', ->
        t = trainWithAttributes isFlt: '0'
        assert.falsey t.isFaulty()

    describe 'isScheduled', ->
      it 'returns true if train is scheduled', ->
        t = trainWithAttributes isSch: '1'
        assert.truthy t.isScheduled()

      it 'returns false if train is not scheduled', ->
        t = trainWithAttributes isSch: '0'
        assert.falsey t.isScheduled()

  describe 'date fields', ->
    describe 'arrivalTime', ->
      it 'returns a native Date object', ->
        t = trainWithAttributes arrT: '20141007 14:50:27'
        expected = new Date(2014, 9, 7, 14, 50, 27)
        actual = t.arrivalTime()

        assert.hasType Date, actual
        assert.equal expected.getTime(), t.arrivalTime().getTime()

    describe 'predictionTime', ->
      it 'returns a native Date object', ->
        t = trainWithAttributes prdt: '20141007 14:49:27'
        expected = new Date(2014, 9, 7, 14, 49, 27)
        actual = t.predictionTime()

        assert.hasType Date, actual
        assert.equal expected.getTime(), t.predictionTime().getTime()

  describe 'floating point fields', ->
    it 'converts latitude to a float', ->
      t = trainWithAttributes lat: '41.87685'
      assert.equal 41.87685, t.latitude()

    it 'converts longitude to a float', ->
      t = trainWithAttributes lon: '-87.6327'
      assert.equal -87.6327, t.longitude()

  describe 'generated fields', ->
    describe 'arrivalMinutes', ->
      it 'converts time difference to minutes', ->
        t = trainWithStubbedMethod [
          arrivalTime: new Date(2014,1,1,12,5,0)
          predictionTime: new Date(2014,1,1,12,0,0)
        ]
        assert.equal 5, t.arrivalMinutes()

      it 'rounds down at < 30 seconds', ->
        t = trainWithStubbedMethod [
          arrivalTime: new Date(2014,1,1,12,1,29)
          predictionTime: new Date(2014,1,1,12,0,0)
        ]
        assert.equal 1, t.arrivalMinutes()

      it 'rounds up at > 30 seconds', ->
        t = trainWithStubbedMethod [
          arrivalTime: new Date(2014,1,1,12,1,31)
          predictionTime: new Date(2014,1,1,12,0,0)
        ]
        assert.equal 2, t.arrivalMinutes()

    describe 'arrivalString', ->
      beforeEach ->
        bond(Dateline, 'getAPTime').through()

      it 'calls Dateline for formatting', ->
        t = trainWithStubbedMethod [arrivalTime: new Date()]
        t.arrivalString()

    describe 'route', ->
      describe 'sets friendly name for abbreviated routes', ->
        it 'handles the Brown line', ->
          t = trainWithAttributes rt: 'Brn'
          assert.equal 'Brown', t.route()

        it 'handles the Green line', ->
          t = trainWithAttributes rt: 'G'
          assert.equal 'Green', t.route()

        it 'handles the Orange line', ->
          t = trainWithAttributes rt: 'Org'
          assert.equal 'Orange', t.route()

        it 'handles the Purple line', ->
          t = trainWithAttributes rt: 'P'
          assert.equal 'Purple', t.route()

        it 'handles the Yellow line', ->
          t = trainWithAttributes rt: 'Y'
          assert.equal 'Yellow', t.route()

      describe 'passes through unabbreviated routes', ->
        it 'handles the Red line', ->
          t = trainWithAttributes rt: 'Red'
          assert.equal 'Red', t.route()

        it 'handles the Blue line', ->
          t = trainWithAttributes rt: 'Blue'
          assert.equal 'Blue', t.route()

        it 'handles the Pink line', ->
          t = trainWithAttributes rt: 'Pink'
          assert.equal 'Pink', t.route()

  describe 'integer fields', ->
    it 'converts destination station ID to an integer', ->
      t = trainWithAttributes destSt: '30182'
      assert.equal 30182, t.destinationId()

    it 'converts direction ID to an integer', ->
      t = trainWithAttributes trDr: '5'
      assert.equal 5, t.directionId()

    it 'converts heading to an integer', ->
      t = trainWithAttributes heading: '269'
      assert.equal 269, t.heading()

    it 'converts run number to an integer', ->
      t = trainWithAttributes rn: '715'
      assert.equal 715, t.runNumber()

    it 'converts station ID to an integer', ->
      t = trainWithAttributes staId: '40160'
      assert.equal 40160, t.stationId()

    it 'converts stop ID to an integer', ->
      t = trainWithAttributes stpId: '30031'
      assert.equal 30031, t.stopId()

  describe 'string fields', ->
    it 'maps destination name', ->
      t = trainWithAttributes destNm: 'Midway'
      assert.equal 'Midway', t.destinationName()

    it 'maps route ID', ->
      t = trainWithAttributes rt: 'Org'
      assert.equal 'Org', t.routeId()

    it 'maps station name', ->
      t = trainWithAttributes staNm: 'LaSalle/Van Buren'
      assert.equal 'LaSalle/Van Buren', t.stationName()

    it 'maps stop description', ->
      t = trainWithAttributes stpDe: 'Service at Inner Loop platform'
      assert.equal 'Service at Inner Loop platform', t.stopDescription()
