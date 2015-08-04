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
    
    @IBOutlet weak var avatar: PFImageView!
    @IBOutlet weak var profileTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let avatarfile = PFUser.currentUser()?.objectForKey("avatar") as? PFFile
        if(avatarfile != nil) {
            avatar.file = avatarfile
            avatar.loadInBackground()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row){
        case 0 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
        case 1 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showSettings()
        case 2 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showUpcomingEvents()
        case 3 : appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
        (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showPastEvents()
        default: appDelegate.centerContainer!.closeDrawerAnimated(true, completion: nil)
            (appDelegate.centerViewController.viewControllers[0] as! MainRootViewController).showProfile()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
