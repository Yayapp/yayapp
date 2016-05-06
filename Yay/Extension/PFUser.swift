//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension PFUser {
    convenience init(withoutDataUsingUser user: User) {
        self.init(withoutDataWithClassName: "_User", objectId: user.objectId)
    }

    convenience init(pointerUsingUser user: User) {
        self.init(withoutDataWithClassName: "User", objectId: user.objectId)
    }

    convenience init(user: User) {
        self.init()

        self.username = user.username

        commonInit(user)
    }

    func commonInit(user: User) {
        if let gender = user.gender {
            self.setObject(gender, forKey: "gender")
        }

        if let newMessage = user.newMessage {
            self.setObject(newMessage, forKey: "newMessage")
        }

        if let attAccepted = user.attAccepted {
            self.setObject(attAccepted, forKey: "attAccepted")
        }

        if let interests = user.interests {
            self.setObject(interests, forKey: "interests")
        }

        if let invites = user.invites {
            self.setObject(invites, forKey: "invites")
        }

        if let eventsReminder = user.eventsReminder {
            self.setObject(eventsReminder, forKey: "eventsReminder")
        }

        if let name = user.name {
            self.setObject(name, forKey: "name")
        }

        if let about = user.about {
            self.setObject(about, forKey: "about")
        }

        if let updatedAt = user.updatedAt {
            self.setObject(updatedAt, forKey: "updatedAt")
        }

        if let authData = user.authData {
            self.setObject(authData, forKey: "authData")
        }

        if let location = user.location {
            self.setObject(PFGeoPoint(geoPoint: location), forKey: "location")
        }

        if let distance = user.distance {
            self.setObject(distance, forKey: "distance")
        }

        if let dateOfBirth = user.dateOfBirth {
            self.setObject(dateOfBirth, forKey: "dob")
        }

        if let avatar = user.avatar?.parseFile {
            self.setObject(avatar, forKey: "avatar")
        }

        if let eventNearby = user.eventNearby {
            self.setObject(eventNearby, forKey: "eventNearby")
        }

        if let token = user.token {
            self.setObject(token, forKey: "token")
        }

        if let createdAt = user.createdAt {
            self.setObject(createdAt, forKey: "createdAt")
        }
        
        if let email = user.email {
            self.setObject(email, forKey: "email")
        }

        self.setObject(user.pendingGroupIDs, forKey: "pendingGroupIDs")
    }
}
