//
//  UIStoryboard.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension UIStoryboard {
    static func auth() -> UIStoryboard? {
        return UIStoryboard(name: "Auth", bundle: nil)
    }

    static func main() -> UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    static func eventsTab() -> UIStoryboard? {
        return UIStoryboard(name: "EventsTab", bundle: nil)
    }

    static func groupsTab() -> UIStoryboard? {
        return UIStoryboard(name: "GroupsTab", bundle: nil)
    }

    static func createEventTab() -> UIStoryboard? {
        return UIStoryboard(name: "CreateEventTab", bundle: nil)
    }

    static func notificationsTab() -> UIStoryboard? {
        return UIStoryboard(name: "NotificationsTab", bundle: nil)
    }

    static func profileTab() -> UIStoryboard? {
        return UIStoryboard(name: "ProfileTab", bundle: nil)
    }
}
