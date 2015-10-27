//
//  Block.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 24.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//
import Foundation

class Block : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Block"
    }
    
    @NSManaged var owner: PFUser
    @NSManaged var user: PFUser
    
}