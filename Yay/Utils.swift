//
//  Utils.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 12.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import Foundation

    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }

    struct Color
    {
        static let PrimaryActiveColor = UIColor(red:CGFloat(90/255.0), green:CGFloat(191/255.0), blue:CGFloat(84/255.0), alpha: 1)
        static let PrimaryBackgroundColor = UIColor(red:CGFloat(239/255.0), green:CGFloat(239/255.0), blue:CGFloat(244/255.0), alpha: 1)
        static let DefaultBorderColor = UIColor(red:CGFloat(164/255.0), green:CGFloat(170/255.0), blue:CGFloat(179/255.0), alpha: 1)
        static let ProfileEditBackground = UIColor(red:CGFloat(219/255.0), green:CGFloat(234/255.0), blue:CGFloat(237/255.0), alpha: 1)
        static let ProfileValuesColor = UIColor(red:CGFloat(153/255.0), green:CGFloat(113/255.0), blue:CGFloat(0/255.0), alpha: 1)
        static let DefaultBarColor = UIColor(red:CGFloat(245/255.0), green:CGFloat(245/255.0), blue:CGFloat(245/255.0), alpha: 1)
        static let EventDetailsProfileIconBorder = UIColor(red:CGFloat(250/255.0), green:CGFloat(214/255.0), blue:CGFloat(117/255.0), alpha: 1)
        static let GenderActiveColor = UIColor(red:CGFloat(90/255.0), green:CGFloat(191/255.0), blue:CGFloat(84/255.0), alpha: 1)
        static let GenderInactiveColor = UIColor(red:CGFloat(124/255.0), green:CGFloat(127/255.0), blue:CGFloat(128/255.0), alpha: 1)
        static let SettingsHeader = UIColor(red:CGFloat(121/255.0), green:CGFloat(205/255.0), blue:CGFloat(205/255.0), alpha: 1)
        
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width
        static let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
        static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS =  UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6 = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    }
