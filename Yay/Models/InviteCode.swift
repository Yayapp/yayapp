//
//  InviteCode.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 02.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class InviteCode: PFObject , PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "InviteCode"
    }
    
    @NSManaged var code: String
    @NSManaged var limit: Int
    @NSManaged var invited: Int
}
