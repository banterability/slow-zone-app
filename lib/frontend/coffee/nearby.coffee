console.log 'navigator', navigator

# if 'geolocation' in navigator

navigator.geolocation.getCurrentPosition (position) ->
  payload = {
    lat: position.coords.latitude
    lng: position.coords.longitude
  }

  successCallback = ->
    console.log 'success', this.responseText

  errorCallback = ->
    alert 'error: everything broke'

  Jaxx.post '/locate', payload, successCallback, errorCallback
