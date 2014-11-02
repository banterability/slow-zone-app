(function() {
  console.log('navigator', navigator);

  navigator.geolocation.getCurrentPosition(function(position) {
    var errorCallback, payload, successCallback;
    payload = {
      lat: position.coords.latitude,
      lng: position.coords.longitude
    };
    successCallback = function() {
      return console.log('success', this.responseText);
    };
    errorCallback = function() {
      return alert('error: everything broke');
    };
    return Jaxx.post('/locate', payload, successCallback, errorCallback);
  });

}).call(this);
