/*
  Bobble
  Simulated time environment for JavaScript
*/
var Bobble = (function(global) {
  return function(src) {
    var originals  = {
      setTimeout: global.setTimeout,
      setInterval: global.setInterval,
      clearTimeout: global.clearTimeout,
      clearInterval: global.clearInterval,
      postMessage: global.postMessage,
      addEventListener: global.addEventListener,
      XMLHttpRequest: global.XMLHttpRequest,
      Date: global.Date
    };
    
    var BobbleAPI = (function(global) {
      var bobbleTime        = 0;
      var timeouts          = [];
      var intervals         = [];
      var posted_messages   = [];
      var message_receivers = [];
      var ajax_requests     = [];
      var ajax_mocks        = {};
      ajax_mocks.length     = 0;
      
      var tcPsh = function(cl, fn, ms) {
        cl.push({
          fn: fn,
          ms: ms,
          lastFired: bobbleTime,
          fireAgain: true
        });
        return cl.length;
      };
      
      function advanceTc(collection, repeat) {
        var tc;
        var i = collection.length;
        while(i--) {
          tc = collection[i];
          if (tc.fireAgain && bobbleTime - tc.lastFired >= tc.ms) {
            tc.fn();
            tc.lastFired = bobbleTime;
            tc.fireAgain = repeat;
          }
        }
      };
      
      function advanceReceivers(receivers, messages) {
        var i, message;
        while(messages.length) {
          message = messages.pop();
          i = receivers.length;
          while(i--) { receivers[i](message); }
        }
      };

      function advanceAjax(ajax_requests){
        var i, request, url;
        while(ajax_requests.length) {
          request = ajax_requests.pop();
          url = request.url;
          i = ajax_requests.length;
          if(ajax_mocks[url] && ajax_mocks[url].length > 0){
            ajax_mocks.length -= 1;
            request.readyState = 4;
            request.responseText = ajax_mocks[url].pop();
            request.onreadystatechange(); 
          }else{
            throw("Nothing was mocked for request "+ url);
          }
        }
      };
      
      var Date = function() {
        var a = arguments, base;
        switch(a.length) {
          case 0: base = new originals.Date(bobbleTime); break;
          case 1: base = new originals.Date(a[0]); break;
          case 2: base = new originals.Date(a[0], a[1]); break;
          case 3: base = new originals.Date(a[0], a[1], a[2]); break;
          case 4: base = new originals.Date(a[0], a[1], a[2], a[3]); break;
          case 5: base = new originals.Date(a[0], a[1], a[2], a[3], a[4]); break;
          case 6: base = new originals.Date(a[0], a[1], a[2], a[3], a[4], a[5]); break;
          case 7: base = new originals.Date(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
        };
        base.__proto__ = Date.prototype;
        return base;
      };
      Date.prototype = { __proto__: originals.Date.prototype, constructor: Date };
      
      return {
        Native: {
          setTimeout: function(fn, ms) { return tcPsh(timeouts, fn, ms); },
          setInterval: function(fn, ms) { return tcPsh(intervals, fn, ms); },
          clearTimeout: function(id) { timeouts[id - 1].fireAgain = false; },
          clearInterval: function(id) { intervals[id - 1].fireAgain = false; },
          postMessage: function(data, targetOrigin) {
            posted_messages.push({
                data: data,
                origin: window.location,
                source: window.location
              });
            },
          addEventListener: function(event, fn, useCapture) {
            if ('message' == event) {
              message_receivers.push(fn);
            } else {
              originals.addEventListener.apply(originals, arguments);
            }
          },
          XMLHttpRequest: function(){
            return {
              open: function(){ 
                var a = arguments; 
                // GET /json
                this.url = a[0] + " " + a[1]
                ajax_requests.push(this)
              },
              getResponseHeader: function(){ }
            }
          },
          Date: Date
        },
        Controls: {
          advanceToTime: function(time) {
            if (time < bobbleTime) {
              throw("Can't go back in time");
            } else {
              bobbleTime = time;
              advanceReceivers(message_receivers, posted_messages);
              advanceTc(timeouts, false); // timeouts which don't repeat
              advanceTc(intervals, true); // intervals which do repeat
              advanceAjax(ajax_requests)
            }
          },
          mock: function(url, response){
            ajax_mocks.length += 1;
            if(ajax_mocks[url]){
              ajax_mocks[url].push(response);
            } else {
              ajax_mocks[url] = [response];
            }
          },
          verifyMocks: function(){
            if(ajax_mocks.length != 0){
              throw("Mocks were set but not used")
            }
          }
        }
      };
    })(global);
    
    this.run = function() {
      var setTimeout     = BobbleAPI.Native.setTimeout;
      var clearTimeout   = BobbleAPI.Native.clearTimeout;
      var setInterval    = BobbleAPI.Native.setInterval;
      var clearInterval  = BobbleAPI.Native.clearInterval;
      var postMessage    = BobbleAPI.Native.postMessage;
      var Date           = BobbleAPI.Native.Date;
      var XMLHttpRequest = BobbleAPI.Native.XMLHttpRequest;
      var alert = function(s) { console.log("alert: %o", s); };
      
      var advanceToTime = BobbleAPI.Controls.advanceToTime;
      var mock          = BobbleAPI.Controls.mock;
      var verifyMocks   = BobbleAPI.Controls.verifyMocks;
      
      // Override definitions of functions attached to the global object
      (function(global) {
        global.setTimeout       = setTimeout;
        global.clearTimeout     = clearTimeout;
        global.setInterval      = setInterval;
        global.clearInterval    = clearInterval;
        global.Date             = Date;
        global.postMessage      = postMessage;
        global.addEventListener = BobbleAPI.Native.addEventListener;
        global.XMLHttpRequest   = XMLHttpRequest;
        
        eval(src);

      })(global);
      
      // Swap original definitions of global functions back into place
      global.setTimeout     = originals.setTimeout;
      global.clearTimeout   = originals.clearTimeout;
      global.setInterval    = originals.setInterval;
      global.clearInterval  = originals.clearInterval;
      global.Date           = originals.Date;
      global.postMessage    = originals.postMessage;
      global.XMLHttpRequest = originals.XMLHttpRequest;
    };
  };
})(this);
