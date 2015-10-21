//
//  Report.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 14.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Report : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Report"
    }
    
    @NSManaged var event: Event
    @NSManaged var user: PFUser
    
}