//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension PFACL {
    convenience init(objectACL: ObjectACL) {
        self.init()

        self.publicReadAccess = objectACL.publicReadAccess ?? false
        self.publicWriteAccess = objectACL.publicWriteAccess ?? false
    }
}
