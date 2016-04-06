//
//  Object.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/5/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Object: Equatable {
    let parseObject: PFObject?

    init() {
        parseObject = PFObject()
    }

    required init?(parseObject: PFObject?) {
        self.parseObject = parseObject
    }

    var objectId: String? {
        get {
            return parseObject?.objectId
        }
        set {
            parseObject?.objectId = objectId
        }
    }

    var ACL: ObjectACL {
        get {
            return ObjectACL(parseACL: (parseObject?.ACL)!)
        }
        set {
            parseObject?.setObject(ACL, forKey: "ACL")
        }
    }
}

func ==(lhs: Object, rhs: Object) -> Bool {
    return lhs.objectId == rhs.objectId
}
