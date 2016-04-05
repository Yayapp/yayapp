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
    }
    var photo: File! {
        get {
            return File(parseFile: parseObject?.objectForKey("photo") as! PFFile)!
        }
    }
    var owner: User? {
        get {
            return User(parseObject: parseObject?.objectForKey("owner") as? PFObject)!
        }
    }
    var isPrivate: Bool {
        get {
            return parseObject?.objectForKey("isPrivate") as! Bool
        }
    }
    var attendees: [User] {
        get {
            let parseObjects = parseObject?.objectForKey("attendees") as! [PFObject]

            return parseObjects.map({ User(parseObject: $0) }) as! [User]
        }
    }
    var location: GeoPoint? {
        get {
            guard let parseGeoPoint = parseObject?.objectForKey("location") as? PFGeoPoint else {
                return nil
            }
            
            return GeoPoint(parseGeoPoint: parseGeoPoint)
        }
    }
    var summary: String {
        get {
            return parseObject?.objectForKey("summary") as! String
        }
    }
}