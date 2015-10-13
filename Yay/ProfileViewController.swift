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
    
    @IBOutlet var profileTable: UITableView!
    @IBOutlet var messagesCountLabel: UILabel!
    @IBOutlet var requestsCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.hidden = true
        ParseHelper.countRequests(PFUser.currentUser()!, completion: {
            count in
            self.requestsCountLabel.text = "\(count)"
        })
        messagesCountLabel.text = "\(Prefs.getMessagesCount())"
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row){
        case 0 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showMessages()
        case 1 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
        case 2 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showHappenings()
        case 3 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showRequests()
        case 4 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showInvite()
        case 5 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showSettings()
        case 6 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showTerms()
        case 7 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showPrivacy()
        default: appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
            (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
        }
    }


}
