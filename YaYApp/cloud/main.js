
var moment = require('cloud/moment-timezone-with-data.js');

// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
//Parse.Cloud.define("hello", function(request, response) {
//  response.success("Hello world!");
//});

Parse.Cloud.job("removePastRequests", function(request, status) {
                // Set up to modify user data
                Parse.Cloud.useMasterKey();
                
                var Event = Parse.Object.extend("Event");
                var query = new Parse.Query(Event);
                query.lessThanOrEqualTo("startDate", new Date())
                
                var Request = Parse.Object.extend("Request");
                var reqQuery = new Parse.Query(Request);
                reqQuery.matchesQuery('event', query);
                reqQuery.doesNotExist('accepted');
                reqQuery.find().then(function(results) {
                                     return Parse.Object.destroyAll(results);
                                     }).then(function() {
                                             // Done
                                             }, function(error) {
                                             // Error
                                             });
                });

Parse.Cloud.afterSave("Block", function(request) {
                      Parse.Cloud.useMasterKey();
                      var user = request.object.get('user');
                      var owner = request.object.get('owner');
                      
                      var Event = Parse.Object.extend("Event");
                      var query = new Parse.Query(Event);
                      query.equalTo("owner", owner);
                      
                      var Request = Parse.Object.extend("Request");
                      var reqQuery = new Parse.Query(Request);
                      reqQuery.equalTo("attendee", user);
                      reqQuery.matchesQuery('event', query);
                      reqQuery.find().then(function(results) {
                                           return Parse.Object.destroyAll(results);
                                           }).then(function() {
                                                   query.equalTo("attendees", user)
                                                   query.include("attendees")
                                                   query.each(function (event) {
                                                              event.remove("attendees",user);
                                                              event.save();      
                                                              })
                                                   }, function(error) {
                                                   // Error
                                                   });
                      
                      
                      });


Parse.Cloud.beforeDelete("Event", function(request, response) {
                         
                         Parse.Cloud.useMasterKey();
                         var Event = Parse.Object.extend("Event");
                         var query = new Parse.Query(Event);
                         query.equalTo("objectId", request.object.id);
                         
                        var Request = Parse.Object.extend("Request");
                         var reqQuery = new Parse.Query(Request);
                         reqQuery.matchesQuery('event', query);
                         reqQuery.find().then(function(results) {
                                              return Parse.Object.destroyAll(results);
                                              }).then(function() {
                                                      response.success("OK")
                                                      }, function(error) {
                                                      response.error(error)
                                                      });
                         });


Parse.Cloud.beforeDelete(Parse.User, function(request, response) {
                         
                         Parse.Cloud.useMasterKey();
                         
                         var Event = Parse.Object.extend("Event");
                         var query = new Parse.Query(Event);
                         query.equalTo("attendees", Parse.User.current())
                         query.include("attendees")
                         query.each(function (event) {
                                    event.remove("attendees",Parse.User.current());
                                    event.save();
                                    })
                         
                         var Request = Parse.Object.extend("Request");
                         var reqQuery = new Parse.Query(Request);
                         reqQuery.equalTo("attendee", Parse.User.current())
                         reqQuery.find().then(function(results) {
                                              return Parse.Object.destroyAll(results);
                                              }).then(function() {
                                                      response.success("OK")
                                                      }, function(error) {
                                                      response.error(error)
                                                      });
                         });

Parse.Cloud.afterSave("Report", function(request) {
                      Parse.Cloud.useMasterKey();
                      var event = request.object.get('event');
                      var Report = Parse.Object.extend("Report");
                      var query = new Parse.Query(Report);
                      query.equalTo("event", event);
                      query.find().then(function(results) {
                                        if (results.length >= 5) {
                                        event.fetch({
                                                    success: function(event) {
                                                    
                                                    var owner = event.get('owner');
                                                    
                                                    var eventName = event.get('name');
                                                    
                                                    event.destroy({});
                                                    
                                                    Parse.Object.destroyAll(results);
                                                    
                                                    
                                                    var pushQuery = new Parse.Query(Parse.Installation);
                                                    pushQuery.equalTo('user', owner);
                                                    
                                                    
                                                    // Send push notification to query
                                                    Parse.Push.send({
                                                                    where: pushQuery,
                                                                    //channels: [ "global" ],
                                                                    data: {
                                                                    "alert": "Your event \""+eventName+"\" has been flagged as inappropriate by other users. Please edit your event and create a new one.",
                                                                    "content-available": 1,
                                                                    "sound":"layerbell.caf"
                                                                    }
                                                                    }, {
                                                                    success: function() {
                                                                    // Push was successful
                                                                    },
                                                                    error: function(error) {
                                                                    throw "Got an error " + error.code + " : " + error.message;
                                                                    }
                                                                    });
                                                    }
                                                    });
                                        }
                                        
                                        }).then(function() {
                                                // Done
                                                }, function(error) {
                                                // Error
                                                });
                      
                      });
Parse.Cloud.afterSave("Message", function(request) {
                      
                      var message = request.object.get('text');
                      var event = request.object.get('event');
                      var user = request.object.get('user');
                      var image = request.object.get('photo');
                      
                      
                      event.fetch({
                                  success: function(event) {
                                  
                                  user.fetch({
                                             success: function(user) {
                                             
                                             var userName = user.get('name');
                                             var eventName = event.get('name');
                                             var array = [];
                                             var attendees = event.get('attendees')
                                             var fullMessage = ""
                                             if (image == null) {
                                             fullMessage = "There is a new message in conversation \"" + eventName + "\" from " + userName + ": " + message
                                             } else {
                                             fullMessage = "There is a new photo in conversation \"" + eventName + "\" from " + userName
                                             }
                                             
                                             for(i = 0; i < attendees.length; i++){
                                                if(user.id != attendees[i].id){
                                                    array[i]= attendees[i].id;
                                                }
                                             }
                                             
                                             var userQuery = new Parse.Query(Parse.User);
                                             userQuery.equalTo('newMessage', true);
                                             userQuery.containedIn('objectId', array);
                                             
                                             var pushQuery = new Parse.Query(Parse.Installation);
                                             pushQuery.matchesQuery('user', userQuery);
                                             
                                             var userQueryN = new Parse.Query(Parse.User);
                                             userQuery.equalTo('newMessage', false)
                                             userQueryN.containedIn('objectId', array);
                                             
                                             var pushQueryN = new Parse.Query(Parse.Installation);
                                             pushQueryN.matchesQuery('user', userQueryN);
                                             
                                             
                                             Parse.Push.send({
                                                             where: pushQueryN,
                                                             data: {
                                                             "content-available": 1,
                                                             "event_id": event.id,
                                                             "id": request.object.id
                                                             }
                                                             }, {
                                                             success: function() {},
                                                             error: function(error) {
                                                             throw "Got an error " + error.code + " : " + error.message;
                                                             }
                                                             });
                                             
                                             Parse.Push.send({
                                                             where: pushQuery,
                                                             data: {
                                                             "alert": fullMessage,
                                                             "content-available": 1,
                                                             "sound":"layerbell.caf",
                                                             "event_id": event.id,
                                                             "id": request.object.id
                                                             }
                                                             }, {
                                                             success: function() {},
                                                             error: function(error) {
                                                             throw "Got an error " + error.code + " : " + error.message;
                                                             }
                                                             });
                                             
                                             }});
                                  }});
                      });
Parse.Cloud.afterSave("Event", function(request) {
                      
                      if(request.object.existed()) {
                      return;
                      }
                      
                      
                      var eventName = request.object.get('name');
                      var location = request.object.get('location');
                      var timeZone = request.object.get('timeZone');
                      var user = request.object.get('owner');
                      
                      
                      var date = moment.tz(new Date(request.object.get('startDate')), timeZone);
                      var dateFormatted = moment(date).format("ddd DD MMM") +" at "+ moment(date).format("H:mm");
                      
                      var userQuery = new Parse.Query(Parse.User);
                      userQuery.withinKilometers("location", location, 20.0);
                      userQuery.equalTo('eventNearby', true);
                      userQuery.notEqualTo('objectId', user.id);
                      
                      
                      // Find devices associated with these users
                      var pushQuery = new Parse.Query(Parse.Installation);
                      pushQuery.matchesQuery('user', userQuery);
                      
                      // Send push notification to query
                      Parse.Push.send({
                                      where: pushQuery,
                                      //channels: [ "global" ],
                                      data: {
                                      alert: "There is a new happening \"" + eventName + "\" on " + dateFormatted + " near you within 20km",
                                      "content-available": 1,
                                      "sound":"layerbell.caf"
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
                                                  alert: "There is a new attendee to happening \"" + eventName + "\"",
                                                  "content-available": 1,
                                                  "sound":"layerbell.caf",
                                                  badge: "Increment",
                                                  "request_id":request.object.id
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
                                                  alert: "Don't forget to participate on happening \""+eventName+"\" on "+dateFormatted,
                                                  "content-available": 1,
                                                  "sound":"layerbell.caf"
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
                                                  alert: "Don't forget to participate on happening \""+eventName+"\" on "+dateFormatted,
                                                  "content-available": 1,
                                                  "sound":"layerbell.caf"
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
                                                             alert: "Attendance to happening \"" + eventName + "\" accepted",
                                                             "content-available": 1,
                                                             "sound":"layerbell.caf"
                                                             }
                                                             }, {
                                                             success: function() {},
                                                             error: function(error) {
                                                             throw "Got an error " + error.code + " : " + error.message;
                                                             }});
                                             }}});
                                  }}});
                      });