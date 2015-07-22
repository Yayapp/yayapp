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
	

	class func getAllEvents(block:EventsResultBlock?) {

		var query = PFQuery(className:Event.parseClassName())
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
		
		ParseHelper.getAllEvents {
			(events: [Event]?, error: NSError?) -> () in
				println("result: \(events!)")
		}
	}
	
}