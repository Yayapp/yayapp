//
//  EventPhoto.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class EventPhoto: Object {
    override init() {
        super.init()

        super.parseObject = PFObject(className: "EventPhoto")
    }

    override init?(parseObject: PFObject?) {
        super.init(parseObject: parseObject)
    }

    var name: String {
        get {
            return parseObject?.objectForKey("name") as! String
        }
    }
    var photo: File {
        get {
            return File(parseFile: parseObject?.objectForKey("photo") as! PFFile)!
        }
    }
    var category: Category {
        get {
            return Category(parseObject: parseObject?.objectForKey("category") as? PFObject)!
        }
    }
}