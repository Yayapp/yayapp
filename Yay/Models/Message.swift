//
//  Conversation.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Message: Object, Notification {
    var event: Event? {
        get {
            return Event(parseObject: parseObject?.objectForKey("event") as? PFObject)
        }
    }
    var group: Category? {
        get {
            return Category(parseObject: parseObject?.objectForKey("group") as? PFObject)
        }
    }
    var user: User! {
        get {
            return User(parseObject: parseObject?.objectForKey("user") as? PFObject)!
        }
    }
    var text: String? {
        get {
            return parseObject?.valueForKey("text") as? String
        }
    }
    var photo: File? {
        get {
            guard let parseFile = parseObject?.valueForKey("photo") as? PFFile else {
                return nil
            }

            return File(parseFile: parseFile)
        }
    }

    func getPhoto() -> File {
        return user.avatar!
    }
    
    func getTitle() -> String {
        if event != nil {
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