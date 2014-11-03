(function() {
  var appendElToList, appendLinkEl, appendTextEl, getNearbyStations, hideSpinner, init, resultsListEl, spinnerEl;

  resultsListEl = document.querySelector('.details');

  spinnerEl = document.querySelector('.spinner');

  appendElToList = function(el) {
    return resultsListEl.appendChild(el);
  };

  appendLinkEl = function(linkHref, linkText, otherText) {
    var distance, el, figCaptionEl, figureEl, figureUnitEl, firstLineEl, link, secondLineEl;
    el = document.createElement('li');
    el.classList.add('cta-train');
    figureEl = document.createElement('figure');
    distance = document.createTextNode(otherText);
    figureUnitEl = document.createElement('span');
    figureUnitEl.classList.add('units');
    figureUnitEl.textContent = 'mi';
    figureEl.appendChild(distance);
    figureEl.appendChild(figureUnitEl);
    el.appendChild(figureEl);
    figCaptionEl = document.createElement('figcaption');
    firstLineEl = document.createElement('div');
    firstLineEl.classList.add('prediction');
    firstLineEl.textContent = linkText;
    secondLineEl = document.createElement('div');
    secondLineEl.classList.add('prediction-age');
    link = document.createElement('a');
    link.href = linkHref;
    link.textContent = 'Arrivals';
    secondLineEl.appendChild(link);
    figCaptionEl.appendChild(firstLineEl);
    figCaptionEl.appendChild(secondLineEl);
    el.appendChild(figCaptionEl);
    return appendElToList(el);
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
          _results.push(appendLinkEl("/station/" + result.id, "" + result.name, result.distance.miles.toFixed(1)));
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
