//
//  DataProxy.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/25/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation

struct DataProxy {
    static var sharedInstance = DataProxy()

    var invitedEventID: String?

    var needsShowEventsListTabHint: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.needsShowEventsListTabHintKey)
        }

        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.needsShowEventsListTabHintKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var needsShowGroupsTabHint: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.needsShowGroupsTabHintKey)
        }

        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.needsShowGroupsTabHintKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var needsShowCreateEventTabHint: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.needsShowCreateEventTabHintKey)
        }

        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.needsShowCreateEventTabHintKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    var needsShowInviteHint: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(Constants.needsShowInviteHintKey)
        }

        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.needsShowInviteHintKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func setNeedsShowAllHints(needsShow: Bool) {
        for key in Constants.allNeedsShowHintKeys {
            NSUserDefaults.standardUserDefaults().setBool(needsShow, forKey: key)
        }

        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
