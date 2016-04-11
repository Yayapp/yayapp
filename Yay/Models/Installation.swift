//
//  Block.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 24.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//
import Foundation

class Installation: Object {
    override init() {
        super.init()

        super.parseObject = PFInstallation()
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var user: User! {
        get {
            return User(parseObject: parseObject?.valueForKey("user") as? PFObject)
        }
        set {
            parseObject?.setValue(PFUser(user: newValue), forKey: "user")
        }
    }
}
