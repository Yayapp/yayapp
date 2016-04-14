//
//  Category.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class Category: Object {
    override init() {
        super.init()

        super.parseObject = PFObject(className: "Category")
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var name: String {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return ""
            }

            return parseObject.objectForKey("name") as? String ?? ""
        }
        set {
            parseObject?.setObject(newValue, forKey: "name")
        }
    }
    var photo: File! {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return File()
            }

            return File(parseFile: parseObject.objectForKey("photo") as! PFFile) ?? File()
        }
        set {
            guard let photo = newValue.parseFile else {
                return
            }

            parseObject?.setObject(photo, forKey: "photo")
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
            guard let owner = newValue else {
                return
            }

            parseObject?.setObject(PFUser(withoutDataUsingUser: owner), forKey: "owner")
        }
    }
    var isPrivate: Bool {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return false
            }

            return parseObject.objectForKey("isPrivate") as? Bool ?? false
        }
    }
    var attendees: [User] {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return []
            }

            let parseObjects = parseObject.objectForKey("attendees") as? [PFObject] ?? []

            return parseObjects.map({ User(parseObject: $0)! })
        }
        set {
            parseObject?.setObject(newValue.map({ PFUser(withoutDataUsingUser: $0) }), forKey: "attendees")
        }
    }
    var location: GeoPoint? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable,
                let parseGeoPoint = parseObject.objectForKey("location") as? PFGeoPoint else {
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return ""
            }

            return parseObject.objectForKey("summary") as? String ?? ""
        }
        set {
            parseObject?.setObject(newValue, forKey: "summary")
        }
    }
}
