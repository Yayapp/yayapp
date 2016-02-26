//
//  Request.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Request : PFObject, PFSubclassing, Notification {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Request"
    }
    
    @NSManaged var event: Event?
    @NSManaged var group: Category?
    @NSManaged var attendee: PFUser
    @NSManaged var accepted: Bool

    
    func getPhoto() -> PFFile {
        if isDecidable() {
            return attendee["avatar"] as! PFFile
        } else {
            if self["event"] != nil {
                return event!.photo
            } else {
                return group!.photo
            }
        }
    }
    
    func getTitle() -> String {
        if self["accepted"] != nil {
            if accepted {
                return "You're in!"
            } else {
                if self["event"] != nil {
                    return "It looked lame anyways. View more events..."
                } else {
                    return "It looked lame anyways. View more groups..."
                }
            }
        } else {
            return "\(attendee.name) sent a request"
        }
    }

    func getText() -> String {
        if self["event"] != nil {
            return event!.name
        } else {
            return group!.name
        }
    }
    
    func isSelectable() -> Bool {
        if self["accepted"] != nil && !accepted {
            return false
        } else {
            return true
        }
    }
    
    func isDecidable() -> Bool {
        return self["accepted"] == nil
    }
    
    func getIcon() -> UIImage {
            if accepted {
                return UIImage(named: "play.png")!
            } else {
                return UIImage(named: "play.png")!
            }
    }
    
}