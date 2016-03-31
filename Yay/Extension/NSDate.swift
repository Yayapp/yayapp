//
//  NSDate.swift
//  Friendzi
//
//  Created by Yuriy B. on 3/31/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

extension NSDate {
    func startOfDay(calendar: NSCalendar) -> NSDate {
        return calendar.startOfDayForDate(self)
    }

    func endOfDay(calendar: NSCalendar) -> NSDate? {
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        return calendar.dateByAddingComponents(components, toDate: startOfDay(calendar), options: NSCalendarOptions())
    }

    func tomorrowDay(calendar: NSCalendar) -> NSDate? {
        let components = NSDateComponents()
        components.second = 1

        guard let endOfToday = NSDate().endOfDay(calendar) else {
            return nil
        }

        return calendar.dateByAddingComponents(components, toDate: endOfToday, options: NSCalendarOptions())
    }
}
