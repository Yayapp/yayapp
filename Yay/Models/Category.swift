//
//  Category.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

class Category : PFObject, PFSubclassing {
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Category"
    }
    
    @NSManaged var name: String
    @NSManaged var photo: PFFile
    @NSManaged var owner: PFUser?
    @NSManaged var isPrivate: Bool
    @NSManaged var attendees: [PFUser]
    @NSManaged var location: PFGeoPoint?
    @NSManaged var summary: String
}