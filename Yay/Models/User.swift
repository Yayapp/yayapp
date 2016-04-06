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
        set {
            guard let username = newValue else {
                return
            }
            
            parseObject?.setObject(username, forKey: "username")
        }
    }

    var gender: Int? {
        get {
            return parseObject?.objectForKey("gender") as? Int
        }
        set {
            guard let gender = newValue else {
                return
            }

            parseObject?.setObject(gender, forKey: "gender")
        }
    }

    var newMessage: Bool? {
        get {
            return parseObject?.objectForKey("newMessage") as? Bool
        }
        set {
            guard let newMessage = newValue else {
                return
            }

            parseObject?.setObject(newMessage, forKey: "newMessage")
        }
    }

    var attAccepted: Bool? {
        get {
            return parseObject?.objectForKey("attAccepted") as? Bool
        }
        set {
            guard let attAccepted = newValue else {
                return
            }

            parseObject?.setObject(attAccepted, forKey: "attAccepted")
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
        set {
            guard let invites = newValue else {
                return
            }

            parseObject?.setObject(invites, forKey: "invites")
        }
    }

    var eventsReminder: Bool? {
        get {
            return parseObject?.objectForKey("eventsReminder") as? Bool
        }
        set {
            guard let eventsReminder = newValue else {
                return
            }

            parseObject?.setObject(eventsReminder, forKey: "eventsReminder")
        }
    }

    var name: String? {
        get {
            return parseObject?.objectForKey("name") as? String
        }
        set {
            guard let name = newValue else {
                return
            }

            parseObject?.setObject(name, forKey: "name")
        }
    }

    var about: String? {
        get {
            return parseObject?.objectForKey("about") as? String
        }
        set {
            guard let about = newValue else {
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

    var authData: NSDictionary? {
        get {
            return parseObject?.objectForKey("authData") as? NSDictionary
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

    var distance: Int? {
        get {
            return parseObject?.objectForKey("distance") as? Int
        }
        set {
            guard let distance = newValue else {
                return
            }

            parseObject?.setObject(distance, forKey: "distance")
        }
    }

    var dateOfBirth: NSDate? {
        get {
            return parseObject?.objectForKey("dob") as? NSDate
        }
    }

    var avatar: File? {
        get {
            guard let parseFile = parseObject?.objectForKey("avatar") as? PFFile else {
                return nil
            }

            return File(parseFile: parseFile)
        }
        set {
            guard let avatar = newValue else {
                return
            }

            parseObject?.setObject(PFFile(file: avatar), forKey: "avatar")
        }
    }

    var eventNearby: Bool? {
        get {
            return parseObject?.objectForKey("eventNearby") as? Bool
        }
        set {
            guard let eventNearby = newValue else {
                return
            }

            parseObject?.setObject(eventNearby, forKey: "eventNearby")
        }
    }

    var token: String? {
        get {
            return parseObject?.objectForKey("token") as? String
        }
        set {
            guard let token = newValue else {
                return
            }
            
            parseObject?.setObject(token, forKey: "token")
        }
    }

    var password: String? {
        get {
            return parseObject?.objectForKey("password") as? String
        }
        set {
            guard let password = newValue else {
                return
            }

            parseObject?.setObject(password, forKey: "password")
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
        set {
            guard let email = newValue else {
                return
            }

            parseObject?.setObject(email, forKey: "email")
        }
    }
}
