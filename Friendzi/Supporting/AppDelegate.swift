//
//  AppDelegate.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SVProgressHUD
import ParseTwitterUtils
import ParseFacebookUtilsV4
import Branch
import Flurry_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainNavigation: UITabBarController?

    let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/325d25d4-305a-11e5-98db-7ceb2e015ed0")
    let ParseAppIDString: String = "u64gQcVtoNGvpS2xq1OniHuumQ5jQJmI3TTbbP1Y"
    let ParseClientKeyString: String = "CnO43FxXa3alSR42IeqJOq3pbLDlNwUd9lDH4kkK"

    var mainStoryBoard: UIStoryboard!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])

        SVProgressHUD.setDefaultMaskType(.Gradient)

        // Checking if app is running iOS 8
//        if (application.respondsToSelector(#selector(UIApplication.registerForRemoteNotifications))) {
//            // Register device for iOS8
//            let notificationSettings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories:nil)
//            application.registerUserNotificationSettings(notificationSettings)
//            application.registerForRemoteNotifications()
//        }

        setupParse()

        Flurry.startSession("XBT2H8327QRT89B23Y5Q");
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        PFTwitterUtils.initializeWithConsumerKey("bfn0pGQNrS0YfQjDDbETcd3Pg",  consumerSecret:"f06sn7JwkMJrOb6xf3gmZmahy9XWojyJ62CTfoNOcYC0okVIVT")

        let rootViewController = self.window!.rootViewController
        mainStoryBoard = rootViewController?.storyboard
        mainNavigation = mainStoryBoard.instantiateViewControllerWithIdentifier("mainTabView") as? UITabBarController

        Flurry.logAllPageViewsForTarget(mainNavigation);
        Flurry.setDebugLogEnabled(true)
        Flurry.setCrashReportingEnabled(true)

        if ParseHelper.sharedInstance.currentUser != nil {
            window!.rootViewController = mainNavigation
            window!.makeKeyAndVisible()
        }

        let branch: Branch = Branch.getInstance()
        branch.initSessionWithLaunchOptions(launchOptions, andRegisterDeepLinkHandler: { params, error in
            if let params = params,
                type = params["type"] as? String where type == "event",
                let eventID = params["objectId"] as? String {
                DataProxy.sharedInstance.invitedEventID = eventID
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.userInvitedToEventNotification, object: nil, userInfo: params)
            }
        })
        
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(notificationSettings)

        return true
    }

    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
        
        let hub = SBNotificationHub.init(connectionString: HUBLISTENACCESS, notificationHubPath: HUBNAME)
        hub.registerNativeWithDeviceToken(deviceToken, tags: Set(["friendzi-iOS"])) { (error) in
            
        }
        
        var newToken = deviceToken.description
        newToken = newToken.stringByReplacingOccurrencesOfString("<", withString: "")
        newToken = newToken.stringByReplacingOccurrencesOfString(">", withString: "")
        newToken = newToken.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("token")
        NSUserDefaults.standardUserDefaults().setObject(newToken, forKey: "token")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.NoData)
        let success: Bool = false
        if let _ = userInfo["event_id"] as? String {
            //                if (centerViewController != nil && centerViewController.viewControllers.last?.isKindOfClass(MessagesTableViewController) == true) {
            //                    let chat = centerViewController.viewControllers.last as! MessagesTableViewController
            //                    if chat.event.objectId == eventId {
            //                        chat.loadMessage(userInfo["id"]! as! String)
            //                        success = true
            //                    } else {
            //                        application.applicationIconBadgeNumber+=1
            //                        Prefs.addMessage(eventId)
            //                        leftViewController.messagesCountLabel.text = "\(Prefs.getMessagesCount())"
            //                    }
            //                } else {
            //                    application.applicationIconBadgeNumber+=1
            //                    Prefs.addMessage(eventId)
            //                    if leftViewController != nil {
            //                        leftViewController.messagesCountLabel.text = "\(Prefs.getMessagesCount())"
            //                    }
            //                }

        }
        if let _ = userInfo["request_id"] as? String {
            //            if (leftViewController != nil) {
            //                leftViewController.requestsCountLabel.text = "\(Int(leftViewController.requestsCountLabel.text!)!+1)"
            //            }
        }
        if !success {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSString {
                    let blurryAlertViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                    blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                    blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                    blurryAlertViewController.aboutText = alert as String
                    mainNavigation!.presentViewController(blurryAlertViewController, animated: true, completion: nil)
                }
            }
        }

        if let needsRefreshGroupsContent = userInfo["needsRefreshGroupsContent"] as? Int where needsRefreshGroupsContent == 1 {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.groupPendingStatusChangedNotification, object: nil)
        }

        if let needsRefreshEventsContent = userInfo["needsRefreshEventsContent"] as? Int where needsRefreshEventsContent == 1 {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.eventPendingStatusChangedNotification, object: nil)
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                     openURL: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = PFInstallation.currentInstallation().badge
        FBSDKAppEvents.activateApp()
    }

    func setupParse() {
        // Enable Parse local data store for user persistence
        Parse.enableLocalDatastore()
        Parse.setApplicationId(ParseAppIDString, clientKey: ParseClientKeyString)

        // Set default ACLs
        let defaultACL: PFACL = PFACL()
        defaultACL.publicReadAccess = true
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
    }

    func gotoMainTabBarScreen() {
        self.window!.rootViewController = self.mainNavigation
        self.window!.makeKeyAndVisible()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SocketIOManager.sharedInstance.disconnetConnection()
    }

}
