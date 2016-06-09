//
//  ProfileViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

final class ProfileViewController: UITableViewController {

    private let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    private var eventsData:[Event]?

    override func viewDidLoad() {
        super.viewDidLoad()
        ParseHelper.getUpcomingPastEvents(ParseHelper.sharedInstance.currentUser!, upcoming: false, block: { result, error in
            if error == nil {
                self.eventsData = result
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
 
    @IBAction func logout(sender: AnyObject) {
        SVProgressHUD.show()

        ParseHelper.logOutInBackgroundWithBlock({ error in
            SVProgressHUD.dismiss()
            guard error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                return
            }

            self.tabBarController?.selectedIndex = 0
            self.navigationController?.popViewControllerAnimated(false)
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.userDidLogoutNotification, object: nil)

            guard let startViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("StartViewController") as? StartViewController else {
                return
            }

            self.appDelegate.window!.rootViewController = startViewController
            self.appDelegate.window!.makeKeyAndVisible()
        })
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let eventsListVC = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ListEventsViewController") as? ListEventsViewController,
            eventsData = eventsData
            where indexPath.row == 1 {
            eventsListVC.eventsData = eventsData
            eventsListVC.currentTitle = "Events Archive"

            navigationController?.pushViewController(eventsListVC, animated: true)
        }
    }
}
