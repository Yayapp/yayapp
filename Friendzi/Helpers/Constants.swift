//
//  Constants.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/15/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
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
typealias UserResultBlock = (User?, NSError?) -> ()
typealias UsersResultBlock = ([User]?, NSError?) -> ()
typealias GeoPointResultBlock = (GeoPoint?, NSError?) -> ()

public struct Constants {
    static let userDidLogoutNotification = "userDidLogoutNotification"
    static let userInvitedToEventNotification = "userInvitedToEventNotification"
    static let groupPendingStatusChangedNotification = "groupPendingStatusChangedNotification"
    static let eventPendingStatusChangedNotification = "eventPendingStatusChangedNotification"

    static let needsShowEventsListTabHintKey = "needsShowEventsListTabHint"
    static let needsShowGroupsTabHintKey = "needsShowGroupsTabHint"
    static let needsShowCreateEventTabHintKey = "needsShowCreateEventTabHintK"
    static let needsShowInviteHintKey = "needsShowInviteHint"

    static let allNeedsShowHintKeys = [needsShowEventsListTabHintKey,
                                       needsShowGroupsTabHintKey,
                                       needsShowCreateEventTabHintKey,
                                       needsShowInviteHintKey]
}
