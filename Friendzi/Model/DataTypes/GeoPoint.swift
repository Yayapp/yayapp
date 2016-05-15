//
//  Category.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class GeoPoint {
    var latitude: Double {
        get {
            return parseGeoPoint.latitude
        }
    }
    var longitude: Double {
        get {
            return parseGeoPoint.longitude
        }
    }

    private var parseGeoPoint: PFGeoPoint

    init() {
        parseGeoPoint = PFGeoPoint()
    }

    init?(parseGeoPoint: PFGeoPoint?) {
        self.parseGeoPoint = parseGeoPoint ?? PFGeoPoint()
    }

    init(latitude: Double, longitude: Double) {
        self.parseGeoPoint = PFGeoPoint(latitude: latitude, longitude: longitude)
    }
}