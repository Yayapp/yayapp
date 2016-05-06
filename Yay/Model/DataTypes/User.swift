//
//  User.swift
//  Friendzi
//
//  Created by Yakiv Kovalsky on 4/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class User: Object {
    override init() {
        super.init()

        super.parseObject = PFUser()
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    init?(object: Object) {
        super.init()
        
        self.parseObject = object.parseObject
    }

    var username: String? {
        get {
            guard let parseUser = parseObject as? PFUser where parseUser.dataAvailable else {
                return nil
            }

            return parseUser.username
        }
        set {
            guard let username = newValue,
                let parseUser = parseObject as? PFUser else {
                    return
            }
            
            parseUser.username = username
        }
    }

    var gender: Int? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("gender") as? Int
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("newMessage") as? Bool
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("attAccepted") as? Bool
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
            guard let parseObjects = parseObject?.objectForKey("interests") as? [PFObject] else {
                return nil
            }

            return parseObjects.map({ Category(parseObject: $0)! })
        }
    }

    var invites: Int? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("invites") as? Int
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("eventsReminder") as? Bool
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
            guard let parseObject = parseObject where parseObject.dataAvailable,
                let name = parseObject.objectForKey("name") as? String else {
                return nil
            }

            return name
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("about") as? String
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("updatedAt") as? NSDate
        }
    }

    var authData: NSDictionary? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("authData") as? NSDictionary
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

    var distance: Int? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("distance") as? Int
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("dob") as? NSDate
        }
    }

    var avatar: File? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable,
                let parseFile = parseObject.objectForKey("avatar") as? PFFile else {
                    return nil
            }

            return File(parseFile: parseFile)
        }
        set {
            guard let avatar = newValue?.parseFile else {
                return
            }

            parseObject?.setObject(avatar, forKey: "avatar")
        }
    }

    var eventNearby: Bool? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("eventNearby") as? Bool
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("token") as? String
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("password") as? String
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
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("createdAt") as? NSDate
        }
    }

    var email: String? {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return nil
            }

            return parseObject.objectForKey("email") as? String
        }
        set {
            guard let email = newValue else {
                return
            }

            parseObject?.setObject(email, forKey: "email")
        }
    }
    var pendingGroupIDs: [String] {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return []
            }

            return parseObject.objectForKey("pendingGroupIDs") as? [String] ?? []
        }
        set {
            parseObject?.setObject(newValue, forKey: "pendingGroupIDs")
        }
    }
    var pendingEventIDs: [String] {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable else {
                return []
            }

            return parseObject.objectForKey("pendingEventIDs") as? [String] ?? []
        }
        set {
            parseObject?.setObject(newValue, forKey: "pendingEventIDs")
        }
    }
}
