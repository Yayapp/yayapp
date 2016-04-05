//
//  File.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

class File {
    var parseFile: PFFile?

    var url: String? {
        get {
            return parseFile?.url
        }
    }

    init?(data: NSData) {
        parseFile = PFFile(data: data)
    }

    init?(parseFile: PFFile) {
        self.parseFile = parseFile
    }
}
