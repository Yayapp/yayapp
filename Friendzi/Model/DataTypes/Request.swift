//
//  Request.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Request: Object, Notification {
    override init() {
        super.init()

        super.parseObject = PFObject(className: "Request")
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var event: Event? {
        get {
            if parseObject?.objectForKey("event") != nil {
                return Event(parseObject: parseObject?.objectForKey("event") as? PFObject)
            } else {
                return nil
            }
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
            parseObject?.setValue(PFUser(withoutDataUsingUser: newValue), forKey: "attendee")
        }
    }
    var accepted: Bool? {
        get {
            return parseObject?.valueForKey("accepted") as? Bool
        }
        set {
            if let newValue = newValue {
                parseObject?.setObject(newValue, forKey: "accepted")
            }
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
        if let accepted = accepted {
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
            return "\(attendee.name ?? "") sent a request"
        }
    }

    func getText() -> String {
        if let event = event {
            return event.name ?? ""
        } else {
            return ""
        }
    }
    
    func isSelectable() -> Bool {
        return accepted ?? true
    }
    
    func isDecidable() -> Bool {
        return accepted ?? true
    }
    
    func getIcon() -> UIImage {
        return UIImage(named: "play.png")!
    }
}