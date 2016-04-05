//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension PFObject {
    convenience init(event: Event) {
        self.init()

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

    convenience init(file: File) {
        self.init()

        if let url = file.url {
            self.setObject(url, forKey: "url")
        }
    }
}
