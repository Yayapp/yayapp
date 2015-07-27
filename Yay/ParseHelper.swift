//
//  ParseHelper.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

typealias EventsResultBlock = ([Event]?, NSError?) -> ()

class ParseHelper {
	

	class func getTodayEvents(block:EventsResultBlock?) {

        let today = NSDate()
        
        let cal = NSCalendar.currentCalendar()
        let startToday = cal.startOfDayForDate(today)
        
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        let endToday = cal.dateByAddingComponents(dayComponent, toDate: startToday, options: NSCalendarOptions.MatchFirst)
        
		var query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: today)
        query.whereKey("startDate", lessThanOrEqualTo: endToday!)
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
    
    class func getThisWeekEvents(block:EventsResultBlock?) {
        
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
	
	class func saveEvent (event: Event) {
		event.saveInBackground();
	}
	
	class func testingEvents() {
		
		var event = Event()
		event.name = "test"
		event.summary = "test description"
		event.category = CategoryType.DANCING
		event.startDate = NSDate()
		
		ParseHelper.saveEvent(event)
		
//		ParseHelper.getAllEvents {
//			(events: [Event]?, error: NSError?) -> () in
//				println("result: \(events!)")
//		}
	}
	
}