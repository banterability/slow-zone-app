resultsListEl = document.querySelector '.details'
spinnerEl = document.querySelector '.spinner'

appendElToList = (el) ->
  resultsListEl.appendChild el

appendLinkEl = (linkHref, linkText, otherText) ->
  el = document.createElement 'li'
  el.classList.add 'cta-train'

  figureEl = document.createElement 'figure'

  distance = document.createTextNode otherText

  figureUnitEl = document.createElement 'span'
  figureUnitEl.classList.add 'units'
  figureUnitEl.textContent = 'mi'

  figureEl.appendChild distance
  figureEl.appendChild figureUnitEl

  el.appendChild figureEl

  figCaptionEl = document.createElement 'figcaption'

  firstLineEl = document.createElement 'div'
  firstLineEl.classList.add 'prediction'
  firstLineEl.textContent = linkText

  secondLineEl = document.createElement 'div'
  secondLineEl.classList.add 'prediction-age'

  link = document.createElement 'a'
  link.href = linkHref
  link.textContent = 'Arrivals'
  secondLineEl.appendChild link

  figCaptionEl.appendChild firstLineEl
  figCaptionEl.appendChild secondLineEl

  el.appendChild figCaptionEl

  appendElToList el

appendTextEl = (contents) ->
  el = document.createElement 'li'
  el.textContent = contents
  appendElToList el

hideSpinner = ->
  spinnerEl.remove()

getNearbyStations = ->
  navigator.geolocation.getCurrentPosition (position) ->
    payload = {
      lat: position.coords.latitude
      lng: position.coords.longitude
    }

    successCallback = ->
      hideSpinner()
      results = JSON.parse(this.responseText)
      for result in results.closestStations
        appendLinkEl "/station/#{result.id}", "#{result.name}", result.distance.miles.toFixed(1)

    errorCallback = ->
      hideSpinner()
      appendTextEl 'Sorry, we were unable to find your location.'

    Jaxx.post '/locate', payload, successCallback, errorCallback

init = ->
  if navigator?.geolocation?
    getNearbyStations()
  else
    hideSpinner()
    appendTextEl 'Sorry, your browser does not support finding your location.'

init()
