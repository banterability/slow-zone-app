resultsListEl = document.querySelector '.details'
spinnerEl = document.querySelector '.spinner'

appendElToList = (contents) ->
  el = document.createElement 'li'
  el.textContent = contents
  resultsListEl.appendChild el

hideSpinner = ->
  spinnerEl.remove()

if navigator?.geolocation?
  navigator.geolocation.getCurrentPosition (position) ->
    payload = {
      lat: position.coords.latitude
      lng: position.coords.longitude
    }

    successCallback = ->
      hideSpinner()
      results = JSON.parse(this.responseText)
      for result in results.closestStations
        appendElToList "#{result.name} – #{result.distance.miles.toFixed(2)} mi"

    errorCallback = ->
      hideSpinner()
      appendElToList 'Sorry, we were unable to find your location.'

    Jaxx.post '/locate', payload, successCallback, errorCallback

else
  hideSpinner()
  appendElToList 'Sorry, your browser does not support finding your location.'
