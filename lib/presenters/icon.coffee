Canvas = require 'canvas'

CTA_COLORS =
  blue: '#00A1DE'
  brown: '#62361B'
  green: '#009B3A'
  orange: '#F9461C'
  pink: '#E27EA6'
  purple: '#522398'
  red: '#C60C30'
  yellow: '#F9E300'

ICON_LAYOUTS =
  1: [
    [0, 0, 100, 100]
  ]
  2: [
    [0, 0, 50, 100] # left
    [50, 0, 50, 100] # right
  ]
  3: [
    [0, 0, 33, 100] # top
    [33, 0, 34, 100] # middle
    [67, 0, 33, 100] # bottom
  ]
  4: [
    [0, 0, 50, 50] # top left
    [50, 0, 50, 50] # top right
    [0, 50, 50, 50] # bottom left
    [50, 50, 50, 50] # bottom right
  ]
  5: [
    [0, 0, 50, 50] # top left
    [50, 0, 50, 50] # top right
    [0, 50, 50, 50] # bottom left
    [50, 50, 50, 50] # bottom right
    [25, 25, 50, 50] # centered on everything
  ]
  6: [
    [0, 0, 33, 50] # top left
    [33, 0, 34, 50] # top middle
    [67, 0, 33, 50] # top right
    [0, 50, 33, 50] # bottom left
    [33, 50, 34, 50] # bottom middle
    [67, 50, 33, 50] # bottom right
  ]

drawIcon = (items) ->
  canvas = new Canvas 100, 100
  ctx = canvas.getContext '2d'

  layout = getLayoutForItems items

  for element, index in layout
    line = items[index]
    ctx.fillStyle = getCTAColor line

    [x, y, width, height] = element
    ctx.fillRect x, y, width, height

  canvas.toDataURL()

getLayoutForItems = (items) ->
  ICON_LAYOUTS[items.length]

getCTAColor = (line) ->
  CTA_COLORS[line.toLowerCase()]


module.exports = {drawIcon}
