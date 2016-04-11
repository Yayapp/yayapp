//
//  Report.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 14.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Report: Object {
    override init() {
        super.init()

        super.parseObject = PFObject(className: "Report")
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var event: Event? {
        get {
            return parseObject?.valueForKey("event") as? Event
        }
        set {
            if let event = newValue {
                parseObject?.setValue(PFObject(event: event), forKey: "event")
            }
        }
    }

    var group: Category? {
        get {
            return parseObject?.valueForKey("group") as? Category
        }
        set {
            guard let group = newValue else {
                return
            }

            parseObject?.setValue(PFObject(category: group), forKey: "group")
        }
    }
    var reportedUser: User? {
        get {
            return User(parseObject: parseObject?.valueForKey("reportedUser") as? PFObject)
        }
        set {
            guard let reportedUser = newValue else {
                return
            }

            parseObject?.setValue(PFUser(user: reportedUser), forKey: "reportedUser")
        }
    }

    var user: User {
        get {
            return User(parseObject: parseObject?.valueForKey("user") as? PFObject)!
        }
        set {
            parseObject?.setValue(PFUser(user: newValue), forKey: "user")
        }
    }
}