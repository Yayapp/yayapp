//
//  ProfileViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var eventsData:[Event]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: false, block: {
                    result, error in
                    if error == nil {
                        self.eventsData = result
                    } else {
                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                    }
                })
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        edgesForExtendedLayout = UIRectEdge.None;
//        ParseHelper.countRequests(PFUser.currentUser()!, completion: {
//            count in
//            self.requestsCountLabel.text = "\(count)"
//            UIApplication.sharedApplication().applicationIconBadgeNumber = count + Prefs.getMessagesCount()
//        })
//        messagesCountLabel.text = "\(Prefs.getMessagesCount())"
    }

    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: false, block: {
//            result, error in
//            if error == nil {
//                self.performSegueWithIdentifier("archive", sender: result)
//            } else {
//                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
//            }
//        })
//        switch (indexPath.row){
//        case 0 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showMessages()
//        case 1 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
//        case 2 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showHappenings()
//        case 3 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showRequests()
//        case 4 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showInvite()
//        case 5 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showSettings()
//        case 6 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showTerms()
//        case 7 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showPrivacy()
//        default: appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
//            (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
//        }
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "archive") {
            let vc = (segue.destinationViewController as! ListEventsViewController)
            vc.eventsData = eventsData!
            vc.title = "Past Events"
        }
    }

    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock({
            error in
            if error == nil {
                let startViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StartViewController") as! StartViewController
                self.navigationController!.popToRootViewControllerAnimated(false)
                self.appDelegate.window!.rootViewController = startViewController
                self.appDelegate.window!.makeKeyAndVisible()
                
            }
        })
    }

}
