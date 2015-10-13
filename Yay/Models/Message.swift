//
//  Conversation.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation
class Message : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Message"
    }
    
    @NSManaged var event: Event
    @NSManaged var user: PFUser
    @NSManaged var text: String?
    @NSManaged var photo: PFFile?
}