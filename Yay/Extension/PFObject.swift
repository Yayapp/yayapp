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

        self.setObject(event.name, forKey: "name")
        self.setObject(event.categories, forKey: "categories")
        self.setObject(event.owner, forKey: "owner")
        self.setObject(event.location, forKey: "location")
        self.setObject(event.startDate, forKey: "startDate")
        self.setObject(event.summary, forKey: "summary")
        self.setObject(event.photo, forKey: "photo")
        self.setObject(event.limit, forKey: "limit")
        self.setObject(event.attendees, forKey: "attendees")
        self.setObject(event.timeZone, forKey: "timeZone")
    }

    convenience init(category: Category) {
        self.init(withoutDataWithClassName: "Category", objectId: category.objectId)

        self.setObject(category.name, forKey: "name")
        self.setObject(category.photo, forKey: "photo")
        self.setObject(category.isPrivate, forKey: "isPrivate")
        self.setObject(category.attendees, forKey: "attendees")
        self.setObject(category.summary, forKey: "summary")

        if let owner = category.owner {
            self.setObject(owner, forKey: "owner")
        }

        if let location = category.location {
            self.setObject(location, forKey: "location")
        }
    }

    convenience init(file: File) {
        self.init()

        if let url = file.url {
            self.setObject(url, forKey: "url")
        }
    }
}
