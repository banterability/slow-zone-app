fs = require "fs"
et = require "elementtree"

module.exports.fromServer = (data) ->
  extractPredictionsFromData(data)

extractPredictionsFromData = (data) ->
    etree = et.parse(data)
    predictions = etree.findall('./eta')
    (buildPrediction(result) for result in predictions)

buildPrediction = (tree) ->
  payload =
    train:
      runNumber: getNodeFromTree 'rn', tree
      route: getNodeFromTree 'rt', tree
      line:
        name: lineName getNodeFromTree('rt', tree)
        class: lineClass getNodeFromTree('rt', tree)
      destination:
        id: getNodeFromTree 'destSt', tree
        name: getNodeFromTree 'destNm', tree
    prediction:
      predictedFor: getTimeNodeFromTree 'arrT', tree
      generatedAt: getTimeNodeFromTree 'prdt', tree
      arrivalTime: prettyTime getTimeNodeFromTree('arrT', tree)
      isApproaching: getBooleanNodeFromTree 'isApp', tree
      isScheduled: getBooleanNodeFromTree 'isSch', tree
      isFaulty: getBooleanNodeFromTree 'isFlt', tree
      isDelayed: getBooleanNodeFromTree 'isDly', tree
      stop:
        id: getNodeFromTree 'stpId', tree
        name: getNodeFromTree 'staNm', tree
    location:
      lat: getNodeFromTree 'lat', tree
      lng: getNodeFromTree 'lon', tree
      hdg: getNodeFromTree 'heading', tree

  payload.prediction.minutes = getMinutesRemaining payload.prediction.generatedAt, payload.prediction.predictedFor
  payload.status = addStatusClasses(payload)
  payload

prettyTime = (time) ->
  "#{time.getHours()}:#{time.getMinutes()}"

findNodeInTree = (node, tree) ->
  tree.find(node)

getNodeFromTree = (node, tree) ->
  node = findNodeInTree node, tree
  return undefined unless node
  node.text

getBooleanNodeFromTree = (node, tree) ->
  boolNode = findNodeInTree node, tree
  return false unless boolNode
  boolNode.text == "1"

getTimeNodeFromTree = (node, tree) ->
  node = getNodeFromTree(node, tree)
  return undefined unless node
  parseTime node

parseTime = (timeString) ->
  [str, year, month, day, hour, min] = timeString.match /(\d{4})(\d{2})(\d{2}) (\d{2}):(\d{2})/
  new Date year, month-1, day, hour, min

getMinutesRemaining = (startDate, endDate) ->
  return undefined unless startDate and endDate
  (endDate - startDate) / (60 * 1000)

lineName = (route) ->
  switch route
    when "Brn" then "Brown"
    when "G" then "Green"
    when "Org" then "Orange"
    when "P" then "Purple"
    when "Y" then "Yellow"
    else route

lineClass = (route) ->
  lineName(route).toLowerCase()

addStatusClasses = (payload) =>
  classes = []
  classes.push "approaching" if payload.prediction.isApproaching
  classes.push "scheduled" if payload.prediction.isScheduled
  classes.push "faulty" if payload.prediction.isFaulty
  classes.push "delayed" if payload.prediction.isDelayed
  classes.join " "

