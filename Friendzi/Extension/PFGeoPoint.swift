//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension PFGeoPoint {
    convenience init(geoPoint: GeoPoint) {
        self.init()

        self.setValue(geoPoint.latitude, forKey: "latitude")
        self.setValue(geoPoint.longitude, forKey: "longitude")
    }
}
