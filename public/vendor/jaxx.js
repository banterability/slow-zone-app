var Jaxx = (function(){
  var createRequest = function(method, url, successCb, errorCb){
    var request = new XMLHttpRequest();

    registerCallback(request, 'load', successCb);
    registerCallback(request, 'error', errorCb);

    request.open(method, url, true);
    request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    return request;
  };

  var registerCallback = function(request, eventType, callback){
    if(callback){
      request.addEventListener(eventType, callback, false);
    }
  };

  return {
    get: function(url, success, error){
      var request = createRequest('get', url, success, error);
      request.send();
    },
    post: function(url, payload, success, error){
      var request = createRequest('post', url, success, error);
      request.setRequestHeader('Content-Type', 'application/json');
      request.send(JSON.stringify(payload));
    }
  };
})();

if (typeof window !== "undefined" && window !== null) {
  window.Jaxx = Jaxx;
} else if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
  module.exports = Jaxx;
}
