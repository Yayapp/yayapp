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

    static let tut: String = "tut"
    static let messages: String = "messages"
    

    static func setPref(pref:String!) {
        userDefaults.setBool(true, forKey: pref)
        userDefaults.synchronize()
    }

    static func getPref(pref:String!)->Bool? {
        return userDefaults.boolForKey(pref)
    }

    static func addMessage(id:String) {
        var messagesCount:[String:Int] = [:]
        if let messagez = userDefaults.dictionaryForKey(messages) as? [String:Int] {
            messagesCount = messagez
        } else {
            messagesCount = [:]
        }
        var addedCount = 1
        if let count = messagesCount[id] {
            addedCount+=count
        } else {
            messagesCount[id] = addedCount
        }
        userDefaults.setObject(messagesCount, forKey: messages)
        userDefaults.synchronize()
    }
    
    static func removeMessage(id:String) -> Int {
        var messagesCount:[String:Int] = [:]
        var returningCount = 0
        if let messagez = userDefaults.dictionaryForKey(messages) as? [String:Int] {
            messagesCount = messagez
            if let count = messagesCount[id] {
                returningCount = count
            }
            messagesCount.removeValueForKey(id)
            userDefaults.setObject(messagesCount, forKey: messages)
            userDefaults.synchronize()
        }
        return returningCount
        
    }
    
    static func getMessagesCount() -> Int {
        var count:Int = 0
        if let messagez = userDefaults.dictionaryForKey(messages) as? [String:Int] {
            for number in messagez {
                count += number.1
            }
        }
        return count
    }
}
