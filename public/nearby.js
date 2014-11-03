(function() {
  var appendElToList, appendStationEl, appendTextEl, getNearbyStations, hideSpinner, init, resultsListEl, spinnerEl;

  resultsListEl = document.querySelector('.details');

  spinnerEl = document.querySelector('.spinner');

  appendElToList = function(el) {
    return resultsListEl.appendChild(el);
  };

  appendStationEl = function(_arg) {
    var distance, listEl, markup, stationName, stationUrl;
    distance = _arg.distance, stationName = _arg.stationName, stationUrl = _arg.stationUrl;
    markup = "<figure>" + distance + "<span class=\"units\">mi</span></figure>\n<figcaption>\n  <div class=\"main-line\">" + stationName + "</div>\n  <div class=\"second-line\">\n    <a href=\"" + stationUrl + "\">Arrivals</a>\n  </div>\n</figcaption>";
    listEl = document.createElement('li');
    listEl.classList.add('cta-train');
    listEl.innerHTML = markup;
    return appendElToList(listEl);
  };

  appendTextEl = function(contents) {
    var el;
    el = document.createElement('li');
    el.textContent = contents;
    return appendElToList(el);
  };

  hideSpinner = function() {
    return spinnerEl.remove();
  };

  getNearbyStations = function() {
    return navigator.geolocation.getCurrentPosition(function(position) {
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
          _results.push(appendStationEl({
            distance: result.distance.miles.toFixed(1),
            stationName: result.name,
            stationUrl: "/station/" + result.id
          }));
        }
        return _results;
      };
      errorCallback = function() {
        hideSpinner();
        return appendTextEl('Sorry, we were unable to find your location.');
      };
      return Jaxx.post('/locate', payload, successCallback, errorCallback);
    });
  };

  init = function() {
    if ((typeof navigator !== "undefined" && navigator !== null ? navigator.geolocation : void 0) != null) {
      return getNearbyStations();
    } else {
      hideSpinner();
      return appendTextEl('Sorry, your browser does not support finding your location.');
    }
  };

  init();

}).call(this);

//# sourceMappingURL=nearby.js.map
