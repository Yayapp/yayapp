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

        let today = NSDate()
        
        let cal = NSCalendar.currentCalendar()
        let startToday = cal.startOfDayForDate(today)
        
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        let endToday = cal.dateByAddingComponents(dayComponent, toDate: startToday, options: NSCalendarOptions.MatchFirst)
        
		var query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: today)
        query.whereKey("startDate", lessThanOrEqualTo: endToday!)
        if let user = user {
            let location:PFGeoPoint? = user.objectForKey("location") as? PFGeoPoint
            let distance = user.objectForKey("distance") as? Double
            query.whereKey("location", nearGeoPoint: location!, withinKilometers: distance!)
            
            if let dob = user["dob"] as? NSDate {
                let age = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: dob )
                query.whereKey("minAge", lessThanOrEqualTo: age)
                query.whereKey("maxAge", greaterThanOrEqualTo: age)
            }
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
        
        
        let today = NSDate()
        
        let cal = NSCalendar.currentCalendar()
        let startToday = cal.startOfDayForDate(today)
        
        
        let weekEndDay = 7-cal.components(NSCalendarUnit.CalendarUnitWeekday, fromDate: today).weekday
        
        let dayComponent = NSDateComponents()
        dayComponent.day = weekEndDay
        
        let endWeek = cal.dateByAddingComponents(dayComponent, toDate: startToday, options: NSCalendarOptions.MatchFirst)
        
        var query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: today)
        query.whereKey("startDate", lessThanOrEqualTo: endWeek!)
        if let user = user {
            let location:PFGeoPoint? = user.objectForKey("location") as? PFGeoPoint
            let distance = user.objectForKey("distance") as? Double
            query.whereKey("location", nearGeoPoint: location!, withinKilometers: distance!)
            if let dob = user["dob"] as? NSDate {
                let age = NSCalendar.currentCalendar().component(NSCalendarUnit.CalendarUnitYear, fromDate: dob )
                query.whereKey("minAge", lessThanOrEqualTo: age)
                query.whereKey("maxAge", greaterThanOrEqualTo: age)
            }
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
	
	class func testingEvents() {
		
		var event = Event()
		event.name = "test"
		event.summary = "test description"
		event.category = Category()
		event.startDate = NSDate()
		
//		ParseHelper.saveEvent(event)
		
//		ParseHelper.getAllEvents {
//			(events: [Event]?, error: NSError?) -> () in
//				println("result: \(events!)")
//		}
	}
	
}