//
//  AppDelegate.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit
import MMDrawerController
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var centerContainer: MMDrawerController?
    var centerViewController:MainNavigationController!
    var leftViewController:ProfileViewController!
    var mainStoryBoard: UIStoryboard!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("u64gQcVtoNGvpS2xq1OniHuumQ5jQJmI3TTbbP1Y",
            clientKey: "CnO43FxXa3alSR42IeqJOq3pbLDlNwUd9lDH4kkK")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let rootViewController = self.window!.rootViewController
        
        mainStoryBoard = rootViewController?.storyboard
        
        centerViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("MainNavigationController") as! MainNavigationController
        
        leftViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        
        let navLeft = UINavigationController(rootViewController: leftViewController)
        
        centerContainer = MMDrawerController(centerViewController: centerViewController, leftDrawerViewController: navLeft)
        
        centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        centerContainer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

