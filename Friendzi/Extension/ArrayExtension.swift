//
//  ArrayExtension.swift
//  Friendzi
//
//  Created by Er on 5/18/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension Array {
    func combine(separator: String) -> String{
        var str : String = ""
        for (idx, item) in self.enumerate() {
            str += "\(item)"
            if idx < self.count-1 {
                str += separator
            }
        }
        return str
    }
}