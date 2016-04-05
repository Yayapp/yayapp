//
//  User.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class User: Object {
    var username: String? {
        get {
            return parseObject?.objectForKey("username") as? String
        }
    }

    var gender: Int? {
        get {
            return parseObject?.objectForKey("gender") as? Int
        }
        set {
            guard let gender = gender else {
                return
            }

            parseObject?.setObject(gender, forKey: "gender")
        }
    }

    var newMessage: Bool? {
        get {
            return parseObject?.objectForKey("newMessage") as? Bool
        }
    }

    var attAccepted: Bool? {
        get {
            return parseObject?.objectForKey("attAccepted") as? Bool
        }
    }

    var interests: [Category]? {
        get {
            return parseObject?.objectForKey("interests") as? [Category]
        }
    }

    var invites: Int? {
        get {
            return parseObject?.objectForKey("invites") as? Int
        }
    }

    var eventsReminder: Bool? {
        get {
            return parseObject?.objectForKey("eventsReminder") as? Bool
        }
    }

    var name: String? {
        get {
            return parseObject?.objectForKey("name") as? String
        }
    }

    var about: String? {
        get {
            return parseObject?.objectForKey("about") as? String
        }
        set {
            guard let about = about else {
                return
            }

            parseObject?.setObject(about, forKey: "about")
        }
    }

    var updatedAt: NSDate? {
        get {
            return parseObject?.objectForKey("updatedAt") as? NSDate
        }
    }

    var authData: [String : Any?]? {
        get {
            return parseObject?.objectForKey("authData") as? Dictionary
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

    var distance: Int? {
        get {
            return parseObject?.objectForKey("distance") as? Int
        }
    }

    var dateOfBirth: NSDate? {
        get {
            return parseObject?.objectForKey("dob") as? NSDate
        }
    }

    var avatar: File? {
        get {
            return parseObject?.objectForKey("avatar") as? File
        }
        set {
            guard let avatar = avatar else {
                return
            }

            parseObject?.setObject(PFFile(file: avatar), forKey: "avatar") // NEED CONVERT THIS
        }
    }

    var eventNearby: Bool? {
        get {
            return parseObject?.objectForKey("eventNearby") as? Bool
        }
    }

    var token: String? {
        get {
            return parseObject?.objectForKey("token") as? String
        }
    }

    var createdAt: NSDate? {
        get {
            return parseObject?.objectForKey("createdAt") as? NSDate
        }
    }

    var email: String? {
        get {
            return parseObject?.objectForKey("email") as? String
        }
    }
}
