(function() {
  var appendElToList, resultsList;

  resultsList = document.querySelector('.details');

  appendElToList = function(contents) {
    var el;
    el = document.createElement('li');
    el.textContent = contents;
    return resultsList.appendChild(el);
  };

  if ((typeof navigator !== "undefined" && navigator !== null ? navigator.geolocation : void 0) != null) {
    console.log('starting');
    navigator.geolocation.getCurrentPosition(function(position) {
      var errorCallback, payload, successCallback;
      payload = {
        lat: position.coords.latitude,
        lng: position.coords.longitude
      };
      successCallback = function() {
        var result, results, _i, _len, _ref, _results;
        results = JSON.parse(this.responseText);
        _ref = results.closestStations;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          _results.push(appendElToList("" + result.name + " – " + (result.distance.miles.toFixed(2)) + " mi"));
        }
        return _results;
      };
      errorCallback = function() {
        return appendElToList('Geolocation request failed');
      };
      return Jaxx.post('/locate', payload, successCallback, errorCallback);
    });
  } else {
    appendElToList('Cannot locate');
  }

}).call(this);
