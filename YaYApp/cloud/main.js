
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
                                                   query.equalTo("attendeeIDs", user.id)
                                                   query.each(function (event) {
                                                              event.remove("attendeeIDs", user.id);
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
                         query.equalTo("attendeeIDs", Parse.User.current().id)
                         query.include("attendeeIDs")
                         query.each(function (event) {
                                    event.remove("attendeeIDs", Parse.User.current().id);
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

Parse.Cloud.beforeSave("Report", function(request, response) {
    var reportedUser = request.object.get("reportedUser")

    if (reportedUser == undefined) {
        response.success()

        return
    }

    var query = new Parse.Query(Parse.Object.extend("Report"))
    query.equalTo("user", Parse.User.current())
    query.equalTo("reportedUser", reportedUser)
    query.count().then(function(count) {
        if (count > 0) {
            response.error("Report already exists")
        } else {
            response.success()
        }
    }, function(error) {response.error(error)})
})

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
                                             var attendeeIDs = event.get('attendeeIDs')
                                             var fullMessage = ""
                                             if (image == null) {
                                             fullMessage = "There is a new message in conversation \"" + eventName + "\" from " + userName + ": " + message
                                             } else {
                                             fullMessage = "There is a new photo in conversation \"" + eventName + "\" from " + userName
                                             }
                                             
                                             for (i = 0; i < attendeeIDs.length; i++) {
                                                if (user.id != attendeeIDs[i]) {
                                                    array[i] = attendeeIDs[i]
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

Parse.Cloud.afterSave("Request", function(request) {
    Parse.Cloud.useMasterKey()

    var accepted = request.object.get('accepted')
    var attendee = request.object.get('attendee')
    var event = request.object.get('event')
    var group = request.object.get('group')

    var requestedItem
    var isEvent = false

    if (event != undefined) {
        requestedItem = event
        isEvent = true
    } else if (group != undefined) {
        requestedItem = group
    } else {
        console.log("no requested item")

        return
    }

    requestedItem.fetch().then(function(fetchedItem) {
        var owner = fetchedItem.get('owner')
        var itemName = fetchedItem.get('name')

        if (accepted == undefined) {
            var pushQuery = new Parse.Query(Parse.Installation)
            pushQuery.equalTo('user', owner)

            Parse.Push.send({
            where: pushQuery,
            data: {
            alert: "There is a new attendee to happening \"" + itemName + "\"",
                "content-available": 1,
                "sound":"layerbell.caf",
            badge: "Increment",
                "request_id":request.object.id
            }
            }, {
            success: function() {
                attendee.fetch().then(function(attendee) {
                    var pendingEventIDs = attendee.get("pendingEventIDs") == undefined ? [] : attendee.get("pendingEventIDs")
                    var pendingGroupIDs = attendee.get("pendingGroupIDs") == undefined ? [] : attendee.get("pendingGroupIDs")

                    if (isEvent && (pendingEventIDs.indexOf(fetchedItem.id) < 0)) {
                        attendee.add("pendingEventIDs", fetchedItem.id)
                    } else if (pendingGroupIDs.indexOf(fetchedItem.id) < 0) {
                        attendee.add("pendingGroupIDs", fetchedItem.id)
                    }

                    attendee.save().then(function(result) { })
                })
            },
            error: function(error) {
                throw "Got an error " + error.code + " : " + error.message
            }})
        } else {
            var acceptedState = accepted ? "accepted" : "declined"

            attendee.fetch().then(function(user) {
                var pendingEventIDs = attendee.get("pendingEventIDs") == undefined ? [] : attendee.get("pendingEventIDs")
                var pendingGroupIDs = attendee.get("pendingGroupIDs") == undefined ? [] : attendee.get("pendingGroupIDs")
                var updatedArray

                if (isEvent) {
                    updatedArray = pendingEventIDs.filter(function(item) {
                        return item != fetchedItem.id;
                    })
                } else {
                    updatedArray = pendingGroupIDs.filter(function(item) {
                        console.log("item" + item + "fetchedItem.id" + fetchedItem.id)

                        return item != fetchedItem.id;
                    })
                }

                console.log("Set" + updatedArray + "to " + attendee.id + "isEvent: " + isEvent)
                attendee.set(isEvent ? "pendingEventIDs" : "pendingGroupIDs", updatedArray)

                attendee.save(null, {
                success: function(result) {
                    console.log("attendee saved")
                    if (user.get('attAccepted') == true) {
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo('user', user);

                        var refreshContentKey = isEvent ? "needsRefreshEventsContent" : "needsRefreshGroupsContent"

                        Parse.Push.send({
                        where: pushQuery,
                        data: {
                            refreshContentKey : true,
                        alert: "Attendance to happening \"" + itemName + "\"" + acceptedState,
                            "content-available": 1,
                            "sound":"layerbell.caf",
                        }
                        },  {
                        success: function() {
                            console.log("push sent")
                        }, error: function(error) {
                            throw "Got an error " + error.code + " : " + error.message;
                        }
                        })
                    }
                }, error: function(error) {
                    throw "Got an attendee save error " + error.code + " : " + error.message;
                }
                })
            })
        }
    })
})


Parse.Cloud.beforeDelete("Request", function(request, response) {
    Parse.Cloud.useMasterKey()

    var attendee = request.object.get('attendee')
    var event = request.object.get('event')
    var group = request.object.get('group')

    var requestedItem
    var isEvent = false

    if (event != undefined) {
        requestedItem = event
        isEvent = true
    } else if (group != undefined) {
        requestedItem = group
    } else {
        console.log("no requested item")

        return
    }

    attendee.fetch().then(function(attendee) {
        var pendingEventIDs = attendee.get("pendingEventIDs") == undefined ? [] : attendee.get("pendingEventIDs")
        var pendingGroupIDs = attendee.get("pendingGroupIDs") == undefined ? [] : attendee.get("pendingGroupIDs")
        var updatedArray

        if (isEvent) {
            updatedArray = pendingEventIDs.filter(function(item) {
                return item != requestedItem.id;
            })
        } else {
            updatedArray = pendingGroupIDs.filter(function(item) {
                return item != requestedItem.id;
            })
        }

        attendee.set(isEvent ? "pendingEventIDs" : "pendingGroupIDs", updatedArray)

        attendee.save().then(function(result) {
            response.success()
        })
    }, function(error) {response.error(error)})
})
