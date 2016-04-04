//
//  User.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import CoreLocation

struct User {
    var username: String? {
        get {
            return parseUser?.username
        }
    }

    var gender: Int? {
        get {
            return parseUser?.objectForKey("gender") as? Int
        }
    }

    var newMessage: Bool? {
        get {
            return parseUser?.objectForKey("newMessage") as? Bool
        }
    }

    var attAccepted: Bool? {
        get {
            return parseUser?.objectForKey("attAccepted") as? Bool
        }
    }

    var interests: [Category]? {
        get {
            return parseUser?.objectForKey("interests") as? [Category]
        }
    }

    var invites: Int? {
    get {
    return parseUser?.objectForKey("invites") as? Int
    }
    }

    var eventsReminder: Bool? {
    get {
    return parseUser?.objectForKey("eventsReminder") as? Bool
    }
    }

    var name: String? {
    get {
    return parseUser?.objectForKey("name") as? String
    }
    }

    var about: String? {
    get {
    return parseUser?.objectForKey("about") as? String
    }
    }

    var updatedAt: NSDate? {
    get {
    return parseUser?.objectForKey("updatedAt") as? NSDate
    }
    }

    var authData: [String : AnyObject?]? {
        get {
            return parseUser?.objectForKey("authData") as? Dictionary
        }
    }

    var location: CLLocationCoordinate2D? {
        get {
            return parseUser?.objectForKey("location") as? CLLocationCoordinate2D
        }
    }

    var distance: Int? {
        get {
            return parseUser?.objectForKey("distance") as? Int
        }
    }

    var dateOfBirth: NSDate? {
        get {
            return parseUser?.objectForKey("dob") as? NSDate
        }
    }

    var avatar: File? {
        get {
            return parseUser?.objectForKey("avatar") as? File
        }
    }

    private var parseUser: PFUser?

    init?(parseUser: PFUser?) {
        self.parseUser = parseUser
    }
}
