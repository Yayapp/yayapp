//
//  AdvancedSettingsTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class AdvancedSettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func deleteProfile(){
        guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
            return
        }

        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_DELETE
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.aboutText = "Are you sure you want to delete your profile?"
        blurryAlertViewController.messageText = ""

        let tabbarController = self.tabBarController
        blurryAlertViewController.onUserLoggedOut = { [weak self] error in
            if error == nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.userDidLogoutNotification, object: nil)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(false, forKey: "hasPermission")
                defaults.synchronize()

                guard let startViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("StartViewController") as? StartViewController,
                    appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate else {
                    return
                }

                self?.navigationController?.popToRootViewControllerAnimated(false)
                tabbarController?.selectedIndex = 0
                
                appDelegate.window?.rootViewController = startViewController
                appDelegate.window?.makeKeyAndVisible()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        }

        self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
    }

}
