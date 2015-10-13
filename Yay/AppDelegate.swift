//
//  AppDelegate.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
 
    let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/325d25d4-305a-11e5-98db-7ceb2e015ed0")
    let ParseAppIDString: String = "u64gQcVtoNGvpS2xq1OniHuumQ5jQJmI3TTbbP1Y"
    let ParseClientKeyString: String = "CnO43FxXa3alSR42IeqJOq3pbLDlNwUd9lDH4kkK"
    

    var centerContainer: MMDrawerController?
    var centerViewController:MainNavigationController!
    var leftViewController:ProfileViewController!
    var mainStoryBoard: UIStoryboard!


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        
        // Checking if app is running iOS 8
        if (application.respondsToSelector("registerForRemoteNotifications")) {
            // Register device for iOS8
            let notificationSettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories:nil)
            application.registerUserNotificationSettings(notificationSettings)
            application.registerForRemoteNotifications()
        }
        
        Category.registerSubclass()
        EventPhoto.registerSubclass()
        Event.registerSubclass()
        Request.registerSubclass()
        InviteCode.registerSubclass()
        Message.registerSubclass()
        
        setupParse()
        
        Flurry.startSession("XBT2H8327QRT89B23Y5Q");
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        PFTwitterUtils.initializeWithConsumerKey("bfn0pGQNrS0YfQjDDbETcd3Pg",  consumerSecret:"f06sn7JwkMJrOb6xf3gmZmahy9XWojyJ62CTfoNOcYC0okVIVT")
        
        let rootViewController = self.window!.rootViewController
        
        mainStoryBoard = rootViewController?.storyboard
        
        centerViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("MainNavigationController") as! MainNavigationController
        
        leftViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        
        let navLeft = UINavigationController(rootViewController: leftViewController)
        
        Flurry.logAllPageViewsForTarget(navLeft);
        Flurry.setDebugLogEnabled(true)
        Flurry.setCrashReportingEnabled(true)
        
        centerContainer = MMDrawerController(centerViewController: centerViewController, leftDrawerViewController: navLeft)
        
        centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        centerContainer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView
               
        if (PFUser.currentUser() != nil) {
                window!.rootViewController = centerContainer
                window!.makeKeyAndVisible()
        }
        return true
    }
    
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
            completionHandler(UIBackgroundFetchResult.NoData)
        var success:Bool = false
            if let eventId = userInfo["event_id"] as? String {
                if (centerViewController != nil && centerViewController.viewControllers.last?.isKindOfClass(MessagesTableViewController) == true) {
                    let chat = centerViewController.viewControllers.last as! MessagesTableViewController
                    if chat.event.objectId == eventId {
                        chat.loadMessage(userInfo["id"]! as! String)
                        success = true
                    } else {
                        application.applicationIconBadgeNumber+=1
                        Prefs.addMessage(eventId)
                        leftViewController.messagesCountLabel.text = "\(Prefs.getMessagesCount())"
                    }
                } else {
                    application.applicationIconBadgeNumber+=1
                    Prefs.addMessage(eventId)
                    if leftViewController != nil {
                        leftViewController.messagesCountLabel.text = "\(Prefs.getMessagesCount())"
                    }
                }
                
            }
        if let requestId = userInfo["request_id"] as? String {
            if (leftViewController != nil) {
                leftViewController.requestsCountLabel.text = "\(Int(leftViewController.requestsCountLabel.text!)!+1)"
            }
        }
        if !success {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSString {
                    let blurryAlertViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                    blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                    blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                    blurryAlertViewController.aboutText = alert as String
                    centerViewController.presentViewController(blurryAlertViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let sanitizedURL:NSURL = GSDDeepLink.handleDeepLink(url)
        
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
 
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupParse() {
        // Enable Parse local data store for user persistence
        Parse.enableLocalDatastore()
        Parse.setApplicationId(ParseAppIDString, clientKey: ParseClientKeyString)
        
        
        // Set default ACLs
        let defaultACL: PFACL = PFACL()
        defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
    }
    
}

