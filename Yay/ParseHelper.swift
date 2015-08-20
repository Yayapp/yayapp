//
//  ParseHelper.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

typealias EventsResultBlock = ([Event]?, NSError?) -> ()
typealias CategoriesResultBlock = ([Category]?, NSError?) -> ()
typealias EventPhotosResultBlock = ([EventPhoto]?, NSError?) -> ()

class ParseHelper {
	

    class func getTodayEvents(user:PFUser?, category:Category?, block:EventsResultBlock?) {

        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = NSDateComponents()
        components.second = NSTimeZone.localTimeZone().secondsFromGMT
        let today = calendar!.dateByAddingComponents(components, toDate: NSDate(), options: nil)
        
        
        let endToday = calendar!.dateByAddingComponents(components, toDate: calendar!.startOfDayForDate(today!), options: nil)
        
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        let startTomorrow = calendar!.dateByAddingComponents(dayComponent, toDate: endToday!, options: NSCalendarOptions.MatchFirst)
        
		var query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: today!)
        query.whereKey("startDate", lessThanOrEqualTo: startTomorrow!)
        query.orderByDescending("startDate")
        if let user = user {
            let location:PFGeoPoint? = user.objectForKey("location") as? PFGeoPoint
            let distance = user.objectForKey("distance") as? Double
            query.whereKey("location", nearGeoPoint: location!, withinKilometers: distance!)
            
            if let dob = user["dob"] as? NSDate {
                let age = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: dob )
                query.whereKey("minAge", lessThanOrEqualTo: age)
                query.whereKey("maxAge", greaterThanOrEqualTo: age)
            }
        } else {
            let location:PFGeoPoint = PFGeoPoint(latitude:TempUser.location!.latitude, longitude:TempUser.location!.longitude)
            query.whereKey("location", nearGeoPoint: location, withinKilometers: Double(100))
        }
        
        if (category != nil) {
            query.whereKey("category", equalTo: category!)
        }
        
		query.findObjectsInBackgroundWithBlock {
			(objects: [AnyObject]?, error: NSError?) -> () in
			
			if error == nil {
				if let objects = objects as? [Event] {
					block!(objects, error)
				}
			} else {
				// Log details of the failure
				println("Error: \(error!) \(error!.userInfo!)")
				block!(nil, error)
			}
		}

	}
    
    class func getThisWeekEvents(user:PFUser?, category:Category?, block:EventsResultBlock?) {
        
        
        var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        calendar!.timeZone = NSTimeZone.localTimeZone()
        let components = NSDateComponents()
        components.second = NSTimeZone.localTimeZone().secondsFromGMT
        let today = calendar!.dateByAddingComponents(components, toDate: NSDate(), options: nil)
        
        let weekEndDay = 9-calendar!.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: today!).weekday
        
        let dayComponent = NSDateComponents()
        dayComponent.day = weekEndDay
        
        let endWeek = calendar!.dateByAddingComponents(dayComponent, toDate: today!, options: NSCalendarOptions.MatchFirst)
        let startNextWeek = calendar!.dateByAddingComponents(components, toDate: calendar!.startOfDayForDate(endWeek!), options: nil)
        
        var query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: today!)
        query.whereKey("startDate", lessThanOrEqualTo: startNextWeek!)
        query.orderByDescending("startDate")
        if let user = user {
            let location:PFGeoPoint? = user.objectForKey("location") as? PFGeoPoint
            let distance = user.objectForKey("distance") as? Double
            query.whereKey("location", nearGeoPoint: location!, withinKilometers: distance!)
            if let dob = user["dob"] as? NSDate {
                let age = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: dob )
                query.whereKey("minAge", lessThanOrEqualTo: age)
                query.whereKey("maxAge", greaterThanOrEqualTo: age)
            }
        } else {
            let location:PFGeoPoint = PFGeoPoint(latitude:TempUser.location!.latitude, longitude:TempUser.location!.longitude)
            query.whereKey("location", nearGeoPoint: location, withinKilometers: Double(100))
        }
        
        if (category != nil) {
            query.whereKey("category", equalTo: category!)
        }
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> () in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
                block!(nil, error)
            }
        }
        
    }

    class func getUpcomingPastEvents(user: PFUser, upcoming:Bool?, block:EventsResultBlock?) {
        
        let today = NSDate()
        var query = PFQuery(className:Event.parseClassName())
        query.whereKey("attendees", equalTo:user)
        query.orderByDescending("startDate")
        if(upcoming != nil) {
            if (upcoming == true) {
                query.whereKey("startDate", greaterThanOrEqualTo: today)
            } else {
                query.whereKey("startDate", lessThan: today)
            }
        }
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> () in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
                block!(nil, error)
            }
        }
        
    }
    
    class func getCategories(block:CategoriesResultBlock?) {
        var query = PFQuery(className:Category.parseClassName())
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> () in
            
            if error == nil {
                if let objects = objects as? [Category] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
                block!(nil, error)
            }
        }
    }
    
    class func getEventPhotos(block:EventPhotosResultBlock?) {
        var query = PFQuery(className:EventPhoto.parseClassName())
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> () in
            
            if error == nil {
                if let objects = objects as? [EventPhoto] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
                block!(nil, error)
            }
        }
    }
    
    class func removeUserEvents(user: PFUser, block:EventsResultBlock?){
        var query = PFQuery(className:Event.parseClassName())
        query.whereKey("owner", equalTo:user)
        query.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]?, error: NSError?) -> () in
            
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