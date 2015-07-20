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

    static let SESSION_ID:String! = "session_id"
    static let LOGIN_TYPE:String! = "login_type"
    

    static func storeSessionId(sessionId:String!) {
        userDefaults.setObject(sessionId, forKey: SESSION_ID)
        userDefaults.synchronize()
    }

    static func resetSessionId() {
        userDefaults.removeObjectForKey(SESSION_ID)
        userDefaults.synchronize()
    }

    static func getSessionId()->String? {
        return userDefaults.stringForKey(SESSION_ID)
    }

    static func getLoginType() -> LoginType? {
        if userDefaults.stringForKey(LOGIN_TYPE) != nil{
            return LoginType(rawValue: userDefaults.stringForKey(LOGIN_TYPE)!)!
        } else {
            return nil
        }
    }

    static func resetLoginType() {
        userDefaults.removeObjectForKey(LOGIN_TYPE)
        userDefaults.synchronize()
    }

    static func storeLoginType(loginType:LoginType!){
        userDefaults.setObject(loginType.rawValue, forKey: LOGIN_TYPE)
        userDefaults.synchronize()
    }
}
