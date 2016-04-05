//
//  Report.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 14.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Report: Object {
    var event: Event? {
        get {
            return parseObject?.valueForKey("event") as? Event
        }
    }

    var group: Category? {
        get {
            return parseObject?.valueForKey("group") as? Category
        }
    }
    var reportedUser: User? {
        get {
            return User(parseObject: parseObject?.valueForKey("reportedUser") as? PFObject)
        }
    }

    var user: User {
        get {
            return User(parseObject: parseObject?.valueForKey("user") as? PFObject)!
        }
    }
}