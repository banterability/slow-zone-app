resultsList = document.querySelector '.details'

appendElToList = (contents) ->
  el = document.createElement 'li'
  el.textContent = contents
  resultsList.appendChild el


if navigator?.geolocation?
  console.log 'starting'
  navigator.geolocation.getCurrentPosition (position) ->
    payload = {
      lat: position.coords.latitude
      lng: position.coords.longitude
    }

    successCallback = ->
      results = JSON.parse(this.responseText)
      for result in results.closestStations
        appendElToList "#{result.name} – #{result.distance.miles.toFixed(2)} mi"

    errorCallback = ->
      appendElToList 'Geolocation request failed'

    Jaxx.post '/locate', payload, successCallback, errorCallback

else
  appendElToList 'Cannot locate'
