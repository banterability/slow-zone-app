fs = require 'fs'
xml = require 'xml-object-stream'

data = fs.createReadStream 'data.xml'
parser = xml.parse(data)

parser.each 'eta', (trainAttrs) ->
  train = new Train trainAttrs
  console.log 'Approaching', train.approaching()
  console.log 'Line', train.line()
  console.log 'Destination', train.destination()

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

  _booleanValue: (value) ->
    if '1' then true else false

# CTA API Docs: http://www.transitchicago.com/developers/ttdocs/default.aspx

class Train extends XMLObject
  approaching: ->
    @getBoolean 'isApp'

  destination: ->
    @getText 'destNm'

  line: ->
    @_trainColor @getText 'rt'

  _trainColor: (value) ->
    if LINE_NAMES[value] then LINE_NAMES[value] else value
