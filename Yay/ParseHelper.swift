//
//  ParseHelper.swift
//  Yay
//
//  Created by Developer on 7/22/15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import Foundation

typealias RequestsResultBlock = ([Request]?, NSError?) -> ()
typealias EventsResultBlock = ([Event]?, NSError?) -> ()
typealias MessagesResultBlock = ([Message]?, NSError?) -> ()
typealias CategoriesResultBlock = ([Category]?, NSError?) -> ()
typealias EventPhotosResultBlock = ([EventPhoto]?, NSError?) -> ()
typealias BoolResultBlock = (Bool?, NSError?) -> ()

class ParseHelper {
    static let gregorianUTCCalendar: NSCalendar? = {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian),
            timeZoneUTC = NSTimeZone(abbreviation: "UTC") else {
                return nil
        }

        calendar.timeZone = timeZoneUTC

        return calendar
    }()

    class func getTodayEvents(user:PFUser?, categories:[Category], block:EventsResultBlock?) {
        let today = NSDate()

        guard let calendar = ParseHelper.gregorianUTCCalendar,
        endOfToday = today.endOfDay(calendar) else {
            block?(nil, nil)

            return
        }

        queryHomeEvents(today.startOfDay(calendar),
                        endDate: endOfToday,
                        user: user,
                        categories: categories,
                        block: block)
	}
    
    class func getTomorrowEvents(user:PFUser?, categories:[Category], block:EventsResultBlock?) {
        let today = NSDate()

        guard let calendar = ParseHelper.gregorianUTCCalendar,
            tomorrow = today.tomorrowDay(calendar),
            endOfTomorrow = tomorrow.endOfDay(calendar) else {
                block?(nil, nil)

                return
        }

        queryHomeEvents(tomorrow.startOfDay(calendar),
                        endDate: endOfTomorrow,
                        user: user,
                        categories: categories,
                        block: block)
    }
    
    class func getLaterEvents(user:PFUser?, categories:[Category], block:EventsResultBlock?) {
        let today = NSDate()

        guard let calendar = ParseHelper.gregorianUTCCalendar,
            tomorrow = today.tomorrowDay(calendar),
            endOfTomorrow = tomorrow.endOfDay(calendar) else {
                block?(nil, nil)

                return
        }

        queryHomeEvents(endOfTomorrow,
                        endDate: nil,
                        user: user,
                        categories: categories,
                        block: block)
    }
    
    class func queryHomeEvents(startDate:NSDate, endDate:NSDate?, user:PFUser!, categories:[Category], block:EventsResultBlock?) {
        
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThanOrEqualTo: startDate)

        if let endDate = endDate {
            query.whereKey("startDate", lessThanOrEqualTo: endDate)
        }

        query.orderByDescending("startDate")
        
            let query1 = PFQuery(className:Block.parseClassName())
            query1.whereKey("user", equalTo:user)
            query.whereKey("owner", doesNotMatchKey: "owner", inQuery: query1)
            let location:PFGeoPoint? = user.objectForKey("location") as? PFGeoPoint
            if let distance = user.objectForKey("distance") as? Double,
                location = location {
                query.whereKey("location", nearGeoPoint: location, withinKilometers: distance)
            }

        if (!categories.isEmpty) {
            query.whereKey("categories", containedIn: categories)
        }

        queryEvent(query, block: block)
    }
    
    class func queryEventsForCategories(user:PFUser!, categories:[Category], block:EventsResultBlock?) {
        
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("startDate", greaterThan: NSDate())
        
        query.orderByDescending("startDate")
        
        let query1 = PFQuery(className:Block.parseClassName())
        query1.whereKey("user", equalTo:user!)
        query.whereKey("owner", doesNotMatchKey: "owner", inQuery: query1)
        let location:PFGeoPoint? = user!.objectForKey("location") as? PFGeoPoint
        if let distance = user.objectForKey("distance") as? Double {
            query.whereKey("location", nearGeoPoint: location!, withinKilometers: distance)
        }
        
        if (!categories.isEmpty) {
            query.whereKey("categories", containedIn: categories)
        }
        
        queryEvent(query, block: block)
    }

    class func getUpcomingPastEvents(user: PFUser, upcoming:Bool, block:EventsResultBlock?) {
        let today = NSDate()

        guard let calendar = ParseHelper.gregorianUTCCalendar else {
            block?(nil, nil)

            return
        }

        let startOfToday = today.startOfDay(calendar)

        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("attendees", equalTo: user)
        query.orderByDescending("startDate")

        if upcoming {
            query.whereKey("startDate", greaterThanOrEqualTo: startOfToday)
        } else {
            query.whereKey("startDate", lessThan: startOfToday)
        }

        queryEvent(query, block: block)
    }
    
    class func getOwnerEvents(user: PFUser, block:EventsResultBlock?) {
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("owner", equalTo:user)
        queryEvent(query, block: block)
    }
    
    class func queryEvent (query:PFQuery, block:EventsResultBlock?) {
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getUserCategories(user: PFUser, block:CategoriesResultBlock?) {
        
        let query = PFQuery(className:Category.parseClassName())
        query.whereKey("attendees", equalTo:user)
        
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Category] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getUserCategoriesForEvent(user: PFUser, block:CategoriesResultBlock?) {
        
        let query1 = PFQuery(className:Category.parseClassName())
        query1.whereKey("owner", equalTo:user)
        
        let query2 = PFQuery(className:Category.parseClassName())
        query2.whereKey("isPrivate", equalTo:false)
        
        let query = PFQuery.orQueryWithSubqueries([query1, query2])
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Category] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getCategories(block:CategoriesResultBlock?) {
        let query = PFQuery(className:Category.parseClassName())
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Category] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func searchCategories(text:String, block:CategoriesResultBlock?) {
        let query = PFQuery(className:Category.parseClassName())
        query.whereKey("name", matchesRegex: text, modifiers: "i")
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Category] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getConversations(user: PFUser, block:EventsResultBlock?) {
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("attendees", equalTo:user)
        query.orderByDescending("startDate")
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getMessages(event:Event, block:MessagesResultBlock?) {
        let query = PFQuery(className:Message.parseClassName())
        query.whereKey("event", equalTo:event)
        query.orderByAscending("createdAt")
//        query.limit = 20
//        query.skip = 20// * page
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Message] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getMessages(group:Category, block:MessagesResultBlock?) {
        let query = PFQuery(className:Message.parseClassName())
        query.whereKey("group", equalTo:group)
        query.orderByAscending("createdAt")
        //        query.limit = 20
        //        query.skip = 20// * page
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Message] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    
    class func getEventPhotos(category:Category, block:EventPhotosResultBlock?) {
        let query = PFQuery(className:EventPhoto.parseClassName())
        query.whereKey("category", equalTo: category)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [EventPhoto] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
   
    class func countReports(event: Event, user:PFUser, completion:(Int)->()) {
        let query = PFQuery(className:Report.parseClassName())
        query.whereKey("user", equalTo:user)
        query.whereKey("event", equalTo:event)
        query.countObjectsInBackgroundWithBlock {
            count, error in
            if error == nil {
                completion(Int(count))
            } else {
                completion(0)
            }
        }
    }
    
    
    class func countRequests(user:PFUser, completion:(Int)->()) {
        let query1 = PFQuery(className:Event.parseClassName())
        query1.whereKey("owner", equalTo:user)
        query1.whereKey("startDate", greaterThanOrEqualTo: NSDate())
        
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("event", matchesQuery: query1)
        query.whereKeyDoesNotExist("accepted")
        query.countObjectsInBackgroundWithBlock {
            count, error in
            if error == nil {
                completion(Int(count))
            } else {
                completion(0)
            }
        }
    }
    
    class func countBlocks(owner:PFUser, user:PFUser, completion:(Int)->()) {
  
        let query = PFQuery(className:Block.parseClassName())
        query.whereKey("owner", equalTo:owner)
        query.whereKey("user", equalTo:user)
        query.countObjectsInBackgroundWithBlock {
            count, error in
            if error == nil {
                completion(Int(count))
            } else {
                completion(0)
            }
        }
    }
    
    class func removeBlocks(owner:PFUser, user:PFUser, completion:(NSError?)->()) {
        
        let query = PFQuery(className:Block.parseClassName())
        query.whereKey("owner", equalTo:owner)
        query.whereKey("user", equalTo:user)
        query.findObjectsInBackgroundWithBlock { blocks, error in
            guard let blocks = blocks as? [Block] where error == nil else {
                completion(error)

                return
            }

            var blocksCount = blocks.count
            
            for block in blocks {
                block.deleteInBackgroundWithBlock({ (_, error) in
                    blocksCount -= 1

                    guard error == nil else {
                        completion(error)

                        return
                    }

                    if blocksCount == 0 {
                        completion(nil)
                    }
                })
            }
        }
    }

    class func getOwnerRequests(user: PFUser, block:RequestsResultBlock?) {
        
        let query1 = PFQuery(className:Event.parseClassName())
        query1.whereKey("owner", equalTo:user)
        query1.whereKey("startDate", greaterThanOrEqualTo: NSDate())
        
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("event", matchesQuery: query1)
        query.whereKeyDoesNotExist("accepted")
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getUserRequests(event:Event, user: PFUser, block:RequestsResultBlock?) {
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("attendee", equalTo:user)
        query.whereKey("event", equalTo:event)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getUserRequests(group:Category, user: PFUser, block:RequestsResultBlock?) {
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("attendee", equalTo:user)
        query.whereKey("group", equalTo:group)
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getRecentMessages(block:MessagesResultBlock?) {
        let query = PFQuery(className:Message.parseClassName())
        query.orderByDescending("createdAt")
    
        query.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Message] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }

    
    class func getRecentRequests(user: PFUser, block:RequestsResultBlock?) {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        let today = NSDate()
        
        let weekEndDay = -7
        
        let dayComponent = NSDateComponents()
        dayComponent.day = weekEndDay
        
        let startDay = calendar!.dateByAddingComponents(dayComponent, toDate: today, options: NSCalendarOptions.MatchFirst)
//        let startNextWeek = calendar!.startOfDayForDate(endWeek!)
        
        let queryEvent = PFQuery(className:Event.parseClassName())
        queryEvent.whereKey("owner", equalTo:user)
        
        let queryGroup = PFQuery(className:Category.parseClassName())
        queryGroup.whereKey("owner", equalTo:user)
        
        let queryFilterEvent = PFQuery(className:Request.parseClassName())
        queryFilterEvent.whereKey("event", matchesQuery: queryEvent)
        queryFilterEvent.whereKey("updatedAt", greaterThanOrEqualTo: startDay!)
        queryFilterEvent.whereKeyDoesNotExist("accepted")
        
        let queryFilterGroup = PFQuery(className:Request.parseClassName())
        queryFilterGroup.whereKey("group", matchesQuery: queryGroup)
        queryFilterGroup.whereKey("updatedAt", greaterThanOrEqualTo: startDay!)
        queryFilterGroup.whereKeyDoesNotExist("accepted")
        
        let queryEventGroup = PFQuery.orQueryWithSubqueries([queryFilterEvent, queryFilterGroup])
        
        let query2 = PFQuery(className:Request.parseClassName())
        query2.whereKey("attendee", equalTo:user)
        query2.whereKey("updatedAt", greaterThanOrEqualTo: startDay!)
        query2.whereKeyExists("accepted")
        
        let queryFinal = PFQuery.orQueryWithSubqueries([queryEventGroup, query2])
        queryFinal.includeKey("attendee")
        queryFinal.includeKey("event")

        queryFinal.findObjectsInBackgroundWithBlock {
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    block!(objects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func declineRequests(event:Event){
        let query = PFQuery(className:Request.parseClassName())
        query.whereKey("event", equalTo:event)
        query.whereKeyDoesNotExist("accepted")
        query.findObjectsInBackgroundWithBlock({
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Request] {
                    for request in objects {
                        UIApplication.sharedApplication().applicationIconBadgeNumber-=1
                        request.accepted = false
                        request.saveInBackground()
                    }
                }
            }
            
        })
    }
    
    class func removeUserEvents(user: PFUser, block:EventsResultBlock?){
        let query = PFQuery(className:Event.parseClassName())
        query.whereKey("owner", equalTo:user)
        query.findObjectsInBackgroundWithBlock({
            objects, error in
            
            if error == nil {
                if let objects = objects as? [Event] {
                    for event in objects {
                        event.deleteInBackground()
                    }
                }
                block!(nil, error)
            }
            
        })
    }
}
