//
//  Event.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class Event : PFObject, PFSubclassing {
	
	override class func initialize() {
		struct Static {
			static var onceToken : dispatch_once_t = 0;
		}
		dispatch_once(&Static.onceToken) {
			self.registerSubclass()
		}
	}
	
	static func parseClassName() -> String {
		return "Event"
	}
	
	@NSManaged var category: String
	@NSManaged var name: String
	@NSManaged var owner: PFUser
	@NSManaged var location: PFGeoPoint
	@NSManaged var address: String
	@NSManaged var startDate: NSDate
	@NSManaged var summary: String
	@NSManaged var photo: PFFile
	
}