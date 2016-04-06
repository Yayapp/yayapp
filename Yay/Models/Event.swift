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
        set {
            parseObject?.setObject(categories.map({ PFObject(category: $0) }), forKey: "categories")
        }
    }
    var name: String {
        get {
            return parseObject?.objectForKey("name") as! String
        }
        set {
            parseObject?.setObject(name, forKey: "name")
        }
    }
    var owner: User {
        get {
            return User(parseObject: parseObject?.objectForKey("owner") as? PFObject)!
        }
        set {
            parseObject?.setObject(PFUser(user: owner), forKey: "owner")
        }
    }
    var location: GeoPoint {
        get {
            return GeoPoint(parseGeoPoint: parseObject?.objectForKey("location") as? PFGeoPoint)!
        }
        set {
            parseObject?.setObject(PFGeoPoint(geoPoint: location), forKey: "location")
        }
    }
    var startDate: NSDate {
        get {
            return parseObject?.objectForKey("startDate") as! NSDate
        }
        set {
            parseObject?.setObject(startDate, forKey: "startDate")
        }
    }
    var summary: String {
        get {
            return parseObject?.objectForKey("summary") as! String
        }
        set {
            parseObject?.setObject(summary, forKey: "summary")
        }
    }
    var photo: File! {
        get {
            return File(parseFile: parseObject?.objectForKey("photo") as! PFFile)!
        }
        set {
            parseObject?.setObject(PFFile(file: photo), forKey: "photo")
        }
    }
    var limit: Int {
        get {
            return parseObject?.objectForKey("limit") as! Int
        }
        set {
            parseObject?.setObject(limit, forKey: "limit")
        }
    }
    var attendees: [User] {
        get {
            let parseObjects = parseObject?.objectForKey("attendees") as! [PFObject]

            return parseObjects.map({ User(parseObject: $0) }) as! [User]
        }
        set {
            parseObject?.setObject(attendees.map({ PFUser(user: $0) }), forKey: "attendees")
        }
    }
    var timeZone: String {
        get {
            return parseObject?.objectForKey("timeZone") as! String
        }
        set {
            parseObject?.setObject(timeZone, forKey: "timeZone")
        }
    }
}