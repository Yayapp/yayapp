//
//  Event.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class Event: Object {
    var categories: [Category] {
        get {
            let parseObjects = parseObject?.objectForKey("categories") as! [PFObject]

            return parseObjects.map({ Category(parseObject: $0) }) as! [Category]
        }
    }
    var name: String {
        get {
            return parseObject?.objectForKey("name") as! String
        }
    }
    var owner: User {
        get {
            return User(parseObject: parseObject?.objectForKey("owner") as? PFObject)!
        }
    }
    var location: GeoPoint {
        get {
            return GeoPoint(parseGeoPoint: parseObject?.objectForKey("location") as! PFGeoPoint)!
        }
    }
    var startDate: NSDate {
        get {
            return parseObject?.objectForKey("startDate") as! NSDate
        }
    }
    var summary: String {
        get {
            return parseObject?.objectForKey("summary") as! String
        }
    }
    var photo: File! {
        get {
            return File(parseFile: parseObject?.objectForKey("photo") as! PFFile)!
        }
    }
    var limit: Int {
        get {
            return parseObject?.objectForKey("limit") as! Int
        }
    }
    var attendees: [User] {
        get {
            let parseObjects = parseObject?.objectForKey("attendees") as! [PFObject]

            return parseObjects.map({ User(parseObject: $0) }) as! [User]
        }
    }
    var timeZone: String {
        get {
            return parseObject?.objectForKey("timeZone") as! String
        }
    }
}