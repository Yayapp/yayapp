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
    
    @IBOutlet weak var profileTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        var tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row){
        case 0 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showMessages()
        case 1 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
        case 2 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showSettings()
        case 3 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showHappenings()
        case 4 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showRequests()
        case 5 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showTerms()
        case 6 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showPrivacy()
        default: appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
            (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
        }
    }


}
