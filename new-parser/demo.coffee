fs = require 'fs'
xml = require 'xml-object-stream'
moment = require 'moment'

data = fs.createReadStream 'data.xml'
parser = xml.parse(data)

parser.each 'eta', (trainAttrs) ->
  train = new Train trainAttrs
  console.log train.toHash()

LINE_NAMES =
  Brn: 'Brown'
  G: 'Green'
  Org: 'Orange'
  P: 'Purple'
  Y: 'Yellow'

class XMLObject
  constructor: (@node) ->

  getText: (key) ->
    @node[key].$text

  getBoolean: (key) ->
    @_booleanValue @getText(key)

  getMomentFromTime: (key) ->
    timeString = @getText key
    moment timeString, 'YYYYMMDD HH:mm:ss'

  _booleanValue: (value) ->
    if value == '1' then true else false

# CTA API Docs: http://www.transitchicago.com/developers/ttdocs/default.aspx

class Train extends XMLObject
  destination: ->
    @getText 'destNm'

  line: ->
    @_trainColor @getText 'rt'

  _trainColor: (value) ->
    if LINE_NAMES[value] then LINE_NAMES[value] else value

  predictedFor: ->
    @getMomentFromTime 'arrT'

  predictedAt: ->
    @getMomentFromTime 'prdt'

  toHash: ->
    train:
      runNumber: @getText 'rn'
      route:
        name: @line()
        class: @line().toLowerCase()
      destination:
        id: @getText 'destSt'
        name: @getText 'destNm'
      location:
        lat: @getText 'lat'
        lng: @getText 'lon'
        heading: @getText 'heading'
    prediction:
      dates:
        predictedFor: @predictedFor
        predictionAt: @predictedAt
      minutes: @predictedFor().diff(@predictedAt(), 'minutes')
      predictedAt: @getMomentFromTime 'prdt'
      flags:
        isApproaching: @getBoolean 'isApp'
        isScheduled: @getBoolean 'isSch'
        isFaulty: @getBoolean 'isFlt'
        isDelayed: @getBoolean 'isDly'
      stop:
        id: @getText 'stpId'
        name: @getText 'staNm'
