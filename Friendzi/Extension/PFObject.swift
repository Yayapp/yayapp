//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension PFObject {
    convenience init(event: Event) {
        self.init(withoutDataWithClassName: "Event", objectId: event.objectId)

        if let eventName = event.name {
            self.setObject(eventName, forKey: "name")
        }

        let parseCategories = event.categories.map({ PFObject(category: $0) })
        self.setObject(parseCategories, forKey: "categories")

        if let owner = event.owner {
            self.setObject(PFUser(withoutDataUsingUser: owner), forKey: "owner")
        }

        self.setObject(PFGeoPoint(geoPoint: event.location), forKey: "location")
        self.setObject(event.startDate, forKey: "startDate")
        self.setObject(event.summary, forKey: "summary")

        if let parsePhoto = event.photo.parseFile {
            self.setObject(parsePhoto, forKey: "photo")
        }

        self.setObject(event.limit, forKey: "limit")

        self.setObject(event.attendeeIDs, forKey: "attendeeIDs")

        self.setObject(event.timeZone, forKey: "timeZone")
    }

    convenience init(category: Category) {
        self.init(withoutDataWithClassName: "Category", objectId: category.objectId)

        self.setObject(category.name, forKey: "name")

        if let parsePhoto = category.photo.parseFile {
            self.setObject(parsePhoto, forKey: "photo")
        }

        self.setObject(category.isPrivate, forKey: "isPrivate")

        self.setObject(category.attendeeIDs, forKey: "attendeeIDs")

        self.setObject(category.summary, forKey: "summary")

        if let owner = category.owner {
            self.setObject(PFUser(withoutDataUsingUser: owner), forKey: "owner")
        }

        if let location = category.location {
            self.setObject(PFGeoPoint(geoPoint:location), forKey: "location")
        }
    }

    convenience init(file: File) {
        self.init()

        if let url = file.url {
            self.setObject(url, forKey: "url")
        }
    }
}
