//
//  Constants.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/15/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

struct Constants {
    static let userDidLogoutNotification = "userDidLogoutNotification"
    static let userInvitedToEventNotification = "userInvitedToEventNotification"

    static let needsShowEventsListTabHintKey = "needsShowEventsListTabHint"
    static let needsShowGroupsTabHintKey = "needsShowGroupsTabHint"
    static let needsShowCreateEventTabHintKey = "needsShowCreateEventTabHintK"
    static let needsShowInviteHintKey = "needsShowInviteHint"

    static let allNeedsShowHintKeys = [needsShowEventsListTabHintKey,
                                       needsShowGroupsTabHintKey,
                                       needsShowCreateEventTabHintKey,
                                       needsShowInviteHintKey]
}
