//
//  Conversation.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation
class Message : PFObject, PFSubclassing, Notification {
    
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
    
    @NSManaged var event: Event?
    @NSManaged var group: Category?
    @NSManaged var user: PFUser
    @NSManaged var text: String?
    @NSManaged var photo: PFFile?
    
    
    func getPhoto() -> PFFile {
        return user["avatar"] as! PFFile
    }
    
    func getTitle() -> String {
        if self["event"] != nil {
            return "\(user.name) in \(event!.name)"
        } else {
            return "\(user.name) in \(group!.name)"
        }
        
    }
    
    func getText() -> String {
        return text!
    }
    
    func isSelectable() -> Bool {
        return true
    }
    
    func isDecidable() -> Bool {
        return false
    }
    
    func getIcon() -> UIImage {
        return UIImage(named: "play.png")!
    }
}