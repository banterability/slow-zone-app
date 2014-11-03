resultsListEl = document.querySelector '.details'
spinnerEl = document.querySelector '.spinner'

appendElToList = (el) ->
  resultsListEl.appendChild el

appendStationEl = ({distance, stationName, stationUrl}) ->
  markup = """
    <figure>#{distance}<span class="units">mi</span></figure>
    <figcaption>
      <div class="prediction">#{stationName}</div>
      <div class="prediction-age">
        <a href="#{stationUrl}">Arrivals</a>
      </div>
    </figcaption>
  """

  listEl = document.createElement 'li'
  listEl.classList.add 'cta-train'
  listEl.innerHTML = markup

  appendElToList listEl

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
        appendStationEl {
          distance: result.distance.miles.toFixed(1)
          stationName: result.name
          stationUrl: "/station/#{result.id}"
        }

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
