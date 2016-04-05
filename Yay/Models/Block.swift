//
//  Block.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 24.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//
import Foundation

class Block: Object {
    var owner: User! {
        get {
            return User(parseObject: parseObject?.valueForKey("owner") as? PFObject)
        }
        set {
            parseObject?.setValue(PFUser(user: owner), forKey: "owner")
        }
    }
    var user: User! {
        get {
            return User(parseObject: parseObject?.valueForKey("user") as? PFObject)
        }
        set {
            parseObject?.setValue(PFUser(user: user), forKey: "user")
        }
    }
}
