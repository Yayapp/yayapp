//
//  Prefs.swift
//  PandaChat
//
//  Created by Nerses Zakoyan on 05.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//
import Foundation

struct Prefs {

    static let userDefaults = NSUserDefaults.standardUserDefaults()

    static let ChatAttendees:String! = "tut_chat_attendees"
    static let HappeningCategory:String! = "tut_happening_category"
    static let HappeningToday:String! = "tut_happening_today"
    static let HappeningsAround:String! = "tut_happenings_around"
    static let Invites:String! = "tut_invites"
    static let MakeHappening:String! = "tut_make_happening"
    static let Menu:String! = "tut_menu"
    static let ProfileSocialRanks:String! = "tut_profile_social_ranks"
    static let SeeAttendees:String! = "tut_see_attendees"
    static let Welcome:String! = "tut_welcome"
    static let MenuHappenings:String! = "tut_menu_happenings"
    

    static func setPref(pref:String!) {
        userDefaults.setBool(true, forKey: pref)
        userDefaults.synchronize()
    }

    static func getPref(pref:String!)->Bool? {
        return userDefaults.boolForKey(pref)
    }

    
}
