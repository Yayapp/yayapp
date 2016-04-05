//
//  ACL.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/5/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class ObjectACL {
    var publicWriteAccess: Bool? {
        didSet {
            parseACL.publicWriteAccess = publicWriteAccess ?? false
        }
    }
    var publicReadAccess: Bool? {
        didSet {
            parseACL.publicReadAccess = publicReadAccess ?? false
        }
    }

    private var parseACL: PFACL

    init() {
        self.parseACL = PFACL()
    }

    init(parseACL: PFACL) {
        self.parseACL = parseACL
    }
}
