//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension PFFile {
    convenience init(file: File) {
        self.init(data: NSData())!

        if let url = file.url {
            self.setValue(url, forKey: "url")
        }
    }
}
