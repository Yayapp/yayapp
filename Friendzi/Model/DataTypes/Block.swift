//
//  Block.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 24.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//
import Foundation

class Block: Object {
    override init() {
        super.init()

        super.parseObject = PFObject(className: "Block")
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var owner: User! {
        get {
            guard let parseObject = parseObject where parseObject.dataAvailable,
                let owner = parseObject.objectForKey("owner") as? PFObject else {
                    return nil
            }

            return User(parseObject: owner)
        }
        set {
            parseObject?.setValue(PFUser(withoutDataUsingUser: newValue), forKey: "owner")
        }
    }
    var user: User! {
        get {
            return User(parseObject: parseObject?.valueForKey("user") as? PFObject)
        }
        set {
            parseObject?.setValue(PFUser(withoutDataUsingUser: newValue), forKey: "user")
        }
    }
}
