//
//  Conversation.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Message: Object, Notification {
    override init() {
        super.init()

        super.parseObject = PFObject(className: "Message")
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

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
            if let group = newValue {
                parseObject?.setValue(PFObject(category: group), forKey: "group")
            }
        }
    }
    var user: User! {
        get {
            return User(parseObject: parseObject?.objectForKey("user") as? PFObject)!
        }
        set {
            parseObject?.setValue(PFUser(withoutDataUsingUser: newValue), forKey: "user") // !
        }
    }
    var text: String? {
        get {
            return parseObject?.valueForKey("text") as? String
        }
        set {
            if let text = newValue {
                parseObject?.setValue(text, forKey: "text")
            }
        }
    }
    var photo: File? {
        get {
            guard let parseFile = parseObject?.valueForKey("photo") as? PFFile else {
                return nil
            }

            return File(parseFile: parseFile)
        }
        set {
            guard let photo = newValue?.parseFile else {
                return
            }

            parseObject?.setObject(photo, forKey: "photo")
        }
    }
    var createdAt: NSDate? {
        get {
            return parseObject?.createdAt
        }
    }

    func getPhoto() -> File {
        return user.avatar!
    }
    
    func getTitle() -> String {
        if event != nil {
            return "\(user.name ?? "") in \(event!.name ?? "")"
        } else {
            return "\(user.name ?? "") in \(group!.name ?? "")"
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