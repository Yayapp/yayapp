//
//  Event.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class Event: Object {
    override init() {
        super.init()
        
        super.parseObject = PFObject(className: "Event")
    }
    
    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var categories: [Category] {
        get {
            guard let parseObjects = parseObject?.objectForKey("categories") as? [PFObject] else {
                return []
            }

            return parseObjects.map({ Category(parseObject: $0)! })
        }
        set {
            parseObject?.setObject(newValue.map({ PFObject(category: $0) }), forKey: "categories")
        }
    }
    var name: String? {
        get {
            return parseObject?.objectForKey("name") as? String
        }
        set {
            parseObject?.setObject(newValue!, forKey: "name")
        }
    }
    var owner: User? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable,
                let owner = parseObject.objectForKey("owner") as? PFObject else {
                    return nil
            }

            return User(parseObject: owner)
        }
        set {
            guard let user = newValue else {
                return
            }

            parseObject?.setObject(PFUser(withoutDataUsingUser: user), forKey: "owner")
        }
    }
    var location: GeoPoint {
        get {
            return GeoPoint(parseGeoPoint: parseObject?.objectForKey("location") as? PFGeoPoint) ?? GeoPoint()
        }
        set {
            parseObject?.setObject(PFGeoPoint(geoPoint: newValue), forKey: "location")
        }
    }
    var startDate: NSDate {
        get {
            return parseObject?.objectForKey("startDate") as? NSDate ?? NSDate()
        }
        set {
            parseObject?.setObject(newValue, forKey: "startDate")
        }
    }
    var summary: String {
        get {
            return parseObject?.objectForKey("summary") as? String ?? ""
        }
        set {
            parseObject?.setObject(newValue, forKey: "summary")
        }
    }
    var photo: File! {
        get {
            return File(parseFile: parseObject?.objectForKey("photo") as! PFFile) ?? File()
        }
        set {
            guard let photo = newValue.parseFile else {
                return
            }

            parseObject?.setObject(photo, forKey: "photo")
        }
    }
    var limit: Int {
        get {
            return parseObject?.objectForKey("limit") as? Int ?? 0
        }
        set {
            parseObject?.setObject(newValue, forKey: "limit")
        }
    }
    var attendeeIDs: [String] {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return []
            }

            let elements = parseObject.objectForKey("attendeeIDs") as? [String] ?? []

            return Array(Set(elements))
        }
        set {
            let uniqueElements = Array(Set(newValue))
            parseObject?.setObject(uniqueElements, forKey: "attendeeIDs")
        }
    }
    var timeZone: String {
        get {
            return parseObject?.objectForKey("timeZone") as? String ?? ""
        }
        set {
            parseObject?.setObject(newValue, forKey: "timeZone")
        }
    }
}