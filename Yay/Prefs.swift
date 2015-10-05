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

    static let tut:String! = "tut"
    

    static func setPref(pref:String!) {
        userDefaults.setBool(true, forKey: pref)
        userDefaults.synchronize()
    }

    static func getPref(pref:String!)->Bool? {
        return userDefaults.boolForKey(pref)
    }

    
}
