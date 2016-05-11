//
//  String.swift
//  Friendzi
//
//  Created by Erison on 5/11/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension String {

    /**
     Returns the localized version of self.
     */
    var localized: String {
        return NSLocalizedString(self,
                                 tableName: nil,
                                 bundle: NSBundle.mainBundle(),
                                 value: "",
                                 comment: "")
    }
}