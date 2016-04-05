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
typealias ErrorResultBlock = (NSError?) -> ()
typealias ObjectResultBlock = (Object?, NSError?) -> ()
typealias DataResultBlock = (NSData?, NSError?) -> ()

class ParseHelper {
    static let sharedInstance = ParseHelper()

    static let gregorianUTCCalendar: NSCalendar? = {
        guard let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian),
            timeZoneUTC = NSTimeZone(abbreviation: "UTC") else {
                return nil
        }

        calendar.timeZone = timeZoneUTC

        return calendar
    }()

    let currentUser = User(parseObject: PFUser.currentUser())

    private static let eventParseClassName = "Event"
    private static let blockParseClassName = "Block"
    private static let categoryParseClassName = "Category"
    private static let messageParseClassName = "Message"
    private static let eventPhotoParseClassName = "EventPhoto"
    private static let reportParseClassName = "Report"
    private static let requestParseClassName = "Request"

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
        
        let query = PFQuery(className: eventParseClassName)
        query.whereKey("startDate", greaterThanOrEqualTo: startDate)

        if let endDate = endDate {
            query.whereKey("startDate", lessThanOrEqualTo: endDate)
        }

        query.orderByDescending("startDate")
        
            let query1 = PFQuery(className: blockParseClassName)
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
        
        let query = PFQuery(className: eventParseClassName)
        query.whereKey("startDate", greaterThan: NSDate())
        
        query.orderByDescending("startDate")
        
        let query1 = PFQuery(className: blockParseClassName)
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

    class func getUpcomingPastEvents(user: User, upcoming:Bool, block:EventsResultBlock?) {
        let today = NSDate()

        guard let calendar = ParseHelper.gregorianUTCCalendar else {
            block?(nil, nil)

            return
        }

        let startOfToday = today.startOfDay(calendar)

        let query = PFQuery(className: eventParseClassName)
        query.whereKey("attendees", equalTo: user)
        query.orderByDescending("startDate")

        if upcoming {
            query.whereKey("startDate", greaterThanOrEqualTo: startOfToday)
        } else {
            query.whereKey("startDate", lessThan: startOfToday)
        }

        queryEvent(query, block: block)
    }
    
    class func getOwnerEvents(user: User, block:EventsResultBlock?) {
        let query = PFQuery(className: eventParseClassName)
        query.whereKey("owner", equalTo:user)
        queryEvent(query, block: block)
    }
    
    class func queryEvent (query:PFQuery, block:EventsResultBlock?) {
        query.findObjectsInBackgroundWithBlock { objects, error in
            if error == nil {

                let mappedObjects = objects.map({ Event(parseObject: $0) }) as! [Event]

                if let mappedObjects = mappedObjects {
                    block!(mappedObjects, error)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                block!(nil, error)
            }
        }
    }
    
    class func getUserCategories(user: User, block:CategoriesResultBlock?) {
        
        let query = PFQuery(className: categoryParseClassName)
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
    
    class func getUserCategoriesForEvent(user: User, block:CategoriesResultBlock?) {
        
        let query1 = PFQuery(className: categoryParseClassName)
        query1.whereKey("owner", equalTo:user)
        
        let query2 = PFQuery(className: categoryParseClassName)
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
        let query = PFQuery(className: categoryParseClassName)
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
        let query = PFQuery(className: categoryParseClassName)
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
        let query = PFQuery(className: eventParseClassName)
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
        let query = PFQuery(className: messageParseClassName)
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
        let query = PFQuery(className: messageParseClassName)
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
        let query = PFQuery(className: eventPhotoParseClassName)
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
        let query = PFQuery(className: reportParseClassName)
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
        let query1 = PFQuery(className: eventParseClassName)
        query1.whereKey("owner", equalTo:user)
        query1.whereKey("startDate", greaterThanOrEqualTo: NSDate())
        
        let query = PFQuery(className: requestParseClassName)
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
    
    class func countBlocks(owner: User, user: User, completion:(Int)->()) {
  
        let query = PFQuery(className: blockParseClassName)
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
    
    class func removeBlocks(owner: User, user: User, completion:(NSError?)->()) {
        
        let query = PFQuery(className: blockParseClassName)
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
        
        let query1 = PFQuery(className: eventParseClassName)
        query1.whereKey("owner", equalTo:user)
        query1.whereKey("startDate", greaterThanOrEqualTo: NSDate())
        
        let query = PFQuery(className: requestParseClassName)
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
        let query = PFQuery(className: requestParseClassName)
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
        let query = PFQuery(className: requestParseClassName)
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
        let query = PFQuery(className: messageParseClassName)
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
        
        let queryEvent = PFQuery(className: eventParseClassName)
        queryEvent.whereKey("owner", equalTo:user)
        
        let queryGroup = PFQuery(className: categoryParseClassName)
        queryGroup.whereKey("owner", equalTo:user)
        
        let queryFilterEvent = PFQuery(className: requestParseClassName)
        queryFilterEvent.whereKey("event", matchesQuery: queryEvent)
        queryFilterEvent.whereKey("updatedAt", greaterThanOrEqualTo: startDay!)
        queryFilterEvent.whereKeyDoesNotExist("accepted")
        
        let queryFilterGroup = PFQuery(className: requestParseClassName)
        queryFilterGroup.whereKey("group", matchesQuery: queryGroup)
        queryFilterGroup.whereKey("updatedAt", greaterThanOrEqualTo: startDay!)
        queryFilterGroup.whereKeyDoesNotExist("accepted")
        
        let queryEventGroup = PFQuery.orQueryWithSubqueries([queryFilterEvent, queryFilterGroup])
        
        let query2 = PFQuery(className: requestParseClassName)
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
        let query = PFQuery(className: requestParseClassName)
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
    
    class func removeUserEvents(user: User, block:EventsResultBlock?) {
        let query = PFQuery(className: eventParseClassName)
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

    class func fetchObject(object: Object, completion:ObjectResultBlock?) {
        object.parseObject?.fetchInBackgroundWithBlock({ (parseObject, error) in
            completion?(Object(parseObject: parseObject), error)
        })
    }

    class func getData(file: File, completion:DataResultBlock?) {
        file.parseFile?.getDataInBackgroundWithBlock({ (data, error) in
            completion?(data, error)
        })
    }

    class func saveObject(object: Object, completion:BoolResultBlock?) {
        object.parseObject?.saveInBackgroundWithBlock(completion)
    }

    class func deleteObject(object: Object, completion:BoolResultBlock?) {
        object.parseObject?.deleteInBackgroundWithBlock(completion)
    }

    class func logOutInBackgroundWithBlock(completion:ErrorResultBlock?) {
        PFUser.logOutInBackgroundWithBlock(completion)
    }
}
