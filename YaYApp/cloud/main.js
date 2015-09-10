var fs = require('fs');
var layer = require('cloud/layer-module.js');
var moment = require('cloud/moment-timezone-with-data.js');

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
                      
                      if(request.object.existed()) {
                        return;
                      }
                      
                      var eventName = request.object.get('name');
                      var location = request.object.get('location');
                      var timeZone = request.object.get('timeZone');
                      
                      var date = moment.tz(new Date(request.object.get('startDate')), timeZone);
                      var dateFormatted = moment(date).format("ddd DD MMM") +" at "+ moment(date).format("H:mm");
                      
                      var userQuery = new Parse.Query(Parse.User);
                      userQuery.withinKilometers("location", location, 20.0);
                      userQuery.equalTo('eventNearby', true);
                      
                      // Find devices associated with these users
                      var pushQuery = new Parse.Query(Parse.Installation);
                      pushQuery.matchesQuery('user', userQuery);
                      
                      // Send push notification to query
                      Parse.Push.send({
                                      where: pushQuery,
                                      //channels: [ "global" ],
                                      data: {
                                      alert: "There is a new happening \"" + eventName + "\" on " + dateFormatted + " near you within 20km"
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

Parse.Cloud.afterSave("Request", function(request) {
                      var accepted = request.object.get('accepted');
                      var user = request.object.get('attendee');
                      var event = request.object.get('event');
                      var owner = event.get('owner');
                      event.fetch({
                                  success: function(event) {
                                  
                                  owner = event.get('owner');
                                  
                                  var timeZone = event.get('timeZone');
                                  
                                  eventName = event.get('name');
                                  if(accepted == null) {
                                  var eventName = event.get('name');
                                  
                                  var pushQuery = new Parse.Query(Parse.Installation);
                                  pushQuery.equalTo('user', owner);
                                  
                                  Parse.Push.send({
                                                  where: pushQuery,
                                                  data: {
                                                  alert: "There is a new attendee to happening \"" + eventName + "\""
                                                  }
                                                  }, {
                                                  success: function() {},
                                                  error: function(error) {
                                                  throw "Got an error " + error.code + " : " + error.message;
                                                  }});
                                  if(owner.get('eventsReminder')){
                                  var pushQuery1 = new Parse.Query(Parse.Installation);
                                  pushQuery1.equalTo('user', user);
                                  var before24 = moment.tz(new Date(event.get('startDate')), timeZone);
                                  before24.setHours(before24.getHours()-24);
                                  var before1 = moment.tz(new Date(event.get('startDate')), timeZone);
                                  before1.setHours(before1.getHours()-1);
                                  
                                  
                                  
                                  var date = moment.tz(new Date(event.get('startDate')), timeZone);
                                  
                                  var dateFormatted = moment(date).format("ddd DD MMM") +" at "+ moment(date).format("H:mm");
                                  
                                  Parse.Push.send({
                                                  where: pushQuery1,
                                                  data: {
                                                  alert: "Don't forget to participate on happening \""+eventName+"\" on "+dateFormatted
                                                  },
                                                  push_time: before24
                                                  }, {
                                                  success: function() {},
                                                  error: function(error) {
                                                  throw "Got an error " + error.code + " : " + error.message;
                                                  }
                                                  });
                                  Parse.Push.send({
                                                  where: pushQuery1,
                                                  data: {
                                                  alert: "Don't forget to participate on happening \""+eventName+"\" on "+dateFormatted
                                                  },
                                                  push_time: before1
                                                  }, {
                                                  success: function() {},
                                                  error: function(error) {
                                                  throw "Got an error " + error.code + " : " + error.message;
                                                  }
                                                  });
                                  }
                                  } else if (accepted) {
                                  user.fetch({
                                             success: function(user) {
                                             if (user.get('attAccepted') == true){
                                             var pushQuery = new Parse.Query(Parse.Installation);
                                             pushQuery.equalTo('user', user);
                                             
                                             Parse.Push.send({
                                                             where: pushQuery,
                                                             data: {
                                                             alert: "Attendance to happening \"" + eventName + "\" accepted"
                                                             }
                                                             }, {
                                                             success: function() {},
                                                             error: function(error) {
                                                             throw "Got an error " + error.code + " : " + error.message;
                                                             }});
                                             }}});
                                  }}});
                      });