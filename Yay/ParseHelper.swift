//
//  ParseHelper.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

typealias RequestsResultBlock = ([Request]?, NSError?) -> ()
typealias EventsResultBlock = ([Event]?, NSError?) -> ()
typealias CategoriesResultBlock = ([Category]?, NSError?) -> ()
typealias EventPhotosResultBlock = ([EventPhoto]?, NSError?) -> ()
typealias InviteCodesResultBlock = ([InviteCode]?, NSError?) -> ()
typealias BoolResultBlock = (Bool?, NSError?) -> ()

class ParseHelper {
	
    class func getTodayEvents(user:PFUser?, categories:[Category], block:EventsResultBlock?) {

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = NSDateComponents()
        components.second = NSTimeZone.localTimeZone().secondsFromGMT
        let today = calendar!.dateByAddingComponents(components, toDate: NSDate(), options: [])
        
        let endToday = calendar!.dateByAddingComponents(components, toDate: calendar!.startOfDayForDate(today!), options: [])
        
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        let startTomorrow = calendar!.dateByAddingComponents(dayComponent, toDate: endToday!, options: NSCalendarOptions.MatchFirst)
        
        queryHomeEvents(today!, endDate: startTomorrow!, user: user!, categories: categories, block: block)
	}
    
    class func getTomorrowEvents(user:PFUser?, categories:[Category], block:EventsResultBlock?) {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = NSDateComponents()
        components.second = NSTimeZone.localTimeZone().secondsFromGMT
        let today = calendar!.dateByAddingComponents(components, toDate: NSDate(), options: [])
        
        let endToday = calendar!.dateByAddingComponents(components, toDate: calendar!.startOfDayForDate(today!), options: [])
        
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        let startTomorrow = calendar!.dateByAddingComponents(dayComponent, toDate: endToday!, options: NSCalendarOptions.MatchFirst)
        dayComponent.day = 2
        let startDayAfterTomorrow = calendar!.dateByAddingComponents(dayComponent, toDate: endToday!, options: NSCalendarOptions.MatchFirst)
        
        queryHomeEvents(startTomorrow!, endDate: startDayAfterTomorrow!, user: user!, categories: categories, block: block)
    }
    
    class func getThisWeekEvents(user:PFUser?, categories:[Category], block:EventsResultBlock?) {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = NSDateComponents()
        components.second = NSTimeZone.localTimeZone().secondsFromGMT
        let today = calendar!.dateByAddingComponents(components, toDate: NSDate(), options: [])
        
        let weekEndDay = 9-calendar!.components(NSCalendarUnit.Weekday, fromDate: today!).weekday
        
        let dayComponent = NSDateComponents()
        dayComponent.day = weekEndDay
        
        let endWeek = calendar!.dateByAddingComponents(dayComponent, toDate: today!, options: NSCalendarOptions.MatchFirst)
        let startNextWeek = calendar!.dateByAddingComponents(components, toDate: calendar!.startOfDayForDate(endWeek!), options: [])

        queryHomeEvents(today!, endDate: startNextWeek!, user: user!, categories: categories, block: block)
    }
    
    class func queryHomeEvents(startDate:NSDate, endDate:NSDate, user:PFUser?, categories:[Category], block:EventsResultBlock?) {
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: startDate)
        query.whereKey("startDate", lessThanOrEqualTo: endDate)
        query.orderByDescending("startDate")
        if let user = user {
            let location:PFGeoPoint? = user.objectForKey("location") as? PFGeoPoint
            let distance = user.objectForKey("distance") as? Double
            query.whereKey("location", nearGeoPoint: location!, withinKilometers: distance!)
            if let dob = user["dob"] as? NSDate {
                let age = NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: dob )
                query.whereKey("minAge", lessThanOrEqualTo: age)
                query.whereKey("maxAge", greaterThanOrEqualTo: age)
            }
        } else {
            let location:PFGeoPoint = PFGeoPoint(latitude:TempUser.location!.latitude, longitude:TempUser.location!.longitude)
            query.whereKey("location", nearGeoPoint: location, withinKilometers: Double(100))
        }
        
        if (!categories.isEmpty) {
            query.whereKey("category", containedIn: categories)
        }
        
        queryEvent(query, block: block)
    }

    class func getUpcomingPastEvents(user: PFUser, upcoming:Bool?, block:EventsResultBlock?) {
        
        let today = NSDate()
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("attendees", equalTo:user)
        query.orderByDescending("startDate")
        if(upcoming != nil) {
            if (upcoming == true) {
                query.whereKey("startDate", greaterThanOrEqualTo: today)
            } else {
                query.whereKey("startDate", lessThan: today)
            }
        }
        queryEvent(query, block: block)
    }
    
    class func getOwnerEvents(user: PFUser, block:EventsResultBlock?) {
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("owner", equalTo:user)
        queryEvent(query, block: block)
    }
    
    class func queryEvent (query:PFQuery, block:EventsResultBlock?) {
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    
    class func getCategories(block:CategoriesResultBlock?) {
        let query = PFQuery(className:Category.parseClassName())
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Category] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getEventPhotos(category:Category, block:EventPhotosResultBlock?) {
        let query = PFQuery(className:EventPhoto.parseClassName())
        query.whereKey("category", equalTo: category)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [EventPhoto] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getInviteCode(code:String, block:InviteCodesResultBlock?) {
        let query = PFQuery(className:InviteCode.parseClassName())
        query.whereKey("code", equalTo: code)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [InviteCode] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func checkIfCodeExist(code:String, block:BoolResultBlock?) {
        let query = PFQuery(className:InviteCode.parseClassName())
        query.whereKey("code", equalTo: code)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [InviteCode] {
                    block!(objects.count>0, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
        
    class func getOwnerRequests(user: PFUser, block:RequestsResultBlock?) {
        
        let query1 = PFQuery(className:Event.parseClassName())
        query1.whereKey("owner", equalTo:user)
        
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("event", matchesQuery: query1)
        query.whereKeyDoesNotExist("accepted")
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getUserRequests(event:Event, user: PFUser, block:RequestsResultBlock?) {
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("attendee", equalTo:user)
        query.whereKey("event", equalTo:event)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func declineRequests(event:Event){
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("event", equalTo:event)
        query.whereKeyDoesNotExist("accepted")
        query.findObjectsInBackgroundWithBlock({
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    for request in objects {
                        request.accepted = false
                        request.saveInBackground()
                    }
                }
            }
            
        })
    }
    
    class func removeUserEvents(user: PFUser, block:EventsResultBlock?){
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("owner", equalTo:user)
        query.findObjectsInBackgroundWithBlock({
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    for event in objects {
                        event.deleteInBackground()
                    }
                }
                block!(nil, error)
            }
            
        })
    }

}