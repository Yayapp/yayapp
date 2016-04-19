//
//  Object.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/5/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class Object: Equatable {
    var parseObject: PFObject?

    init() {
        parseObject = nil
    }

    init?(parseObject: PFObject?) {
        self.parseObject = parseObject
    }

    var objectId: String? {
        get {
            return parseObject?.objectId
        }
        set {
            parseObject?.objectId = newValue
        }
    }

    var ACL: ObjectACL {
        get {
            return ObjectACL(parseACL: (parseObject?.ACL)!)
        }
        set {
            parseObject?.setObject(PFACL(objectACL:newValue), forKey: "ACL")
        }
    }
}

func ==(lhs: Object, rhs: Object) -> Bool {
    return lhs.objectId == rhs.objectId
}
