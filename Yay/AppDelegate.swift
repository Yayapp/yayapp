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
import ParseFacebookUtilsV4


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var layerClient: LYRClient!
 
    let LayerAppIDString: NSURL! = NSURL(string: "")
    let ParseAppIDString: String = "u64gQcVtoNGvpS2xq1OniHuumQ5jQJmI3TTbbP1Y"
    let ParseClientKeyString: String = "CnO43FxXa3alSR42IeqJOq3pbLDlNwUd9lDH4kkK"
    
    //Please note, You must set `LYRConversation *conversation` as a property of the ViewController.
    var conversation: LYRConversation!

    var centerContainer: MMDrawerController?
    var centerViewController:MainNavigationController!
    var leftViewController:ProfileViewController!
    var mainStoryBoard: UIStoryboard!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupParse()
        setupLayer()
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        PFTwitterUtils.initializeWithConsumerKey("3r0IsGvrLLvchitCYLUcKVqCK",  consumerSecret:"76rgAwOz7YDcBPPhWB9jqLOx8HmkA0WxbGM97tcYrFTU2cMmEO")
        
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

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
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
    
    func setupLayer() {
//        layerClient = LYRClient(appID: LayerAppIDString)
//        layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as Set<NSObject>
    }
}

