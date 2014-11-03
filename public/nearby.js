(function() {
  var appendElToList, hideSpinner, resultsListEl, spinnerEl;

  resultsListEl = document.querySelector('.details');

  spinnerEl = document.querySelector('.spinner');

  appendElToList = function(contents) {
    var el;
    el = document.createElement('li');
    el.textContent = contents;
    return resultsListEl.appendChild(el);
  };

  hideSpinner = function() {
    return spinnerEl.remove();
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
        hideSpinner();
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
        hideSpinner();
        return appendElToList('Sorry, we were unable to find your location.');
      };
      return Jaxx.post('/locate', payload, successCallback, errorCallback);
    });
  } else {
    hideSpinner();
    appendElToList('Sorry, your browser does not support finding your location.');
  }

}).call(this);
