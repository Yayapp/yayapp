var fs = require('fs');
var layer = require('cloud/layer-module.js');
var moment = require('cloud/moment.min.js');

var layerProviderID = 'layer:///providers/325c1b08-305a-11e5-9444-7ceb2e015ed0';
var layerKeyID = 'layer:///keys/543e166c-306a-11e5-b8ad-f60e4d0122e7';
var privateKey = fs.readFileSync('cloud/keys/layer-key.js');
layer.initialize(layerProviderID, layerKeyID, privateKey);

Parse.Cloud.define("generateToken", function(request, response) {
    var userID = request.params.userID;
    var nonce = request.params.nonce;
    if (!userID) throw new Error('Missing userID parameter');
    if (!nonce) throw new Error('Missing nonce parameter');
        response.success(layer.layerIdentityToken(userID, nonce));
});


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
//Parse.Cloud.define("hello", function(request, response) {
//  response.success("Hello world!");
//});

Parse.Cloud.afterSave("Event", function(request) {
  // Our "Comment" class has a "text" key with the body of the comment itself
  var eventName = request.object.get('name');
  var location = request.object.get('location');
 
  var date = new Date(request.object.get('startDate'));
  var dateFormatted = moment(date).format("ddd DD MMM") +" at "+ moment(date).format("H:mm");

  var userQuery = new Parse.Query(Parse.User);
  userQuery.withinKilometers("location", location, 100.0);
  userQuery.equalTo('eventNearby', true);

// Find devices associated with these users
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.matchesQuery('user', userQuery);

// Send push notification to query
  Parse.Push.send({
    where: pushQuery,
    //channels: [ "global" ],
    data: {
      alert: "There is a new happening \"" + eventName + "\" on " + dateFormatted + " near you within 100km" 
    }
  }, {
    success: function() {
      // Push was successful
    },
    error: function(error) {
      throw "Got an error " + error.code + " : " + error.message;
    }
  });
});