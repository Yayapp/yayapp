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
    }
    
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
