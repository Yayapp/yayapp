//
//  Block.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 24.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//
import Foundation

class Installation: Object {
    var user: User! {
        get {
            return User(parseObject: parseObject?.valueForKey("user") as? PFObject)
        }
        set {
            parseObject?.setValue(PFUser(user: user), forKey: "user")
        }
    }
}
