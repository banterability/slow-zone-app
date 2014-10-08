class Train
  constructor: (@attributes={}) ->

  routeId: ->
    @attributes.rt

  route: ->
    switch route = @routeId()
      when "Brn" then "Brown"
      when "G" then "Green"
      when "Org" then "Orange"
      when "P" then "Purple"
      when "Y" then "Yellow"
      else route

  toHash: ->
    route:
      id: @routeId()
      name: @route()

module.exports = Train
