//
//  Request.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Request: Object, Notification {
    var event: Event? {
        get {
            return Event(parseObject: parseObject?.objectForKey("event") as? PFObject)
        }
        set {
            if let event = newValue {
                parseObject?.setValue(PFObject(event: event), forKey: "event")
            }
        }
    }
    var group: Category? {
        get {
            return Category(parseObject: parseObject?.objectForKey("group") as? PFObject)
        }
        set {
            guard let group = newValue else {
                return
            }
            
            parseObject?.setValue(PFObject(category: group), forKey: "group")
        }
    }
    var attendee: User! {
        get {
            return User(parseObject: parseObject?.objectForKey("attendee") as? PFObject)!
        }
        set {
            parseObject?.setValue(PFUser(user: attendee), forKey: "attendee")
        }
    }
    var accepted: Bool {
        get {
            return parseObject?.valueForKey("accepted") as? Bool ?? false
        }
        set {
            parseObject?.setObject(accepted, forKey: "accepted")
        }
    }

    func getPhoto() -> File {
        if isDecidable() {
            return attendee.avatar!
        } else {
            if event != nil {
                return event!.photo
            } else {
                return group!.photo
            }
        }
    }
    
    func getTitle() -> String {
        if accepted {
            if accepted {
                return "You're in!"
            } else {
                if event != nil {
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
        if event != nil {
            return event!.name
        } else {
            return group!.name
        }
    }
    
    func isSelectable() -> Bool {
        if accepted && !accepted {
            return false
        } else {
            return true
        }
    }
    
    func isDecidable() -> Bool {
        return accepted
    }
    
    func getIcon() -> UIImage {
        if accepted {
            return UIImage(named: "play.png")!
        } else {
            return UIImage(named: "play.png")!
        }
    }
}