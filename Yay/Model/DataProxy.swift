//
//  DataProxy.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/25/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

struct DataProxy {
    static var sharedInstance = DataProxy()

    var invitedEventID: String?
}
