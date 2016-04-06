//
//  Category.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class Category: Object {
    var name: String {
        get {
            return parseObject?.objectForKey("name") as! String
        }
        set {
            parseObject?.setObject(name, forKey: "name")
        }
    }
    var photo: File! {
        get {
            return File(parseFile: parseObject?.objectForKey("photo") as! PFFile)!
        }
        set {
            guard let photo = newValue else {
                return
            }

            parseObject?.setObject(PFFile(file: photo), forKey: "photo")
        }
    }
    var owner: User? {
        get {
            return User(parseObject: parseObject?.objectForKey("owner") as? PFObject)!
        }
        set {
            guard let owner = newValue else {
                return
            }

            parseObject?.setObject(PFUser(user: owner), forKey: "owner")
        }
    }
    var isPrivate: Bool {
        get {
            return parseObject?.objectForKey("isPrivate") as? Bool ?? false
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
    var location: GeoPoint? {
        get {
            guard let parseGeoPoint = parseObject?.objectForKey("location") as? PFGeoPoint else {
                return nil
            }
            
            return GeoPoint(parseGeoPoint: parseGeoPoint)
        }
        set {
            guard let location = newValue else {
                return
            }

            parseObject?.setObject(PFGeoPoint(geoPoint: location), forKey: "location")
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
}
