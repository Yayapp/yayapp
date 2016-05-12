//
//  SettingsTableViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var attAccepted: UISwitch!
    
    @IBOutlet weak var newMessage: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show()
        ParseHelper.fetchObject(ParseHelper.sharedInstance.currentUser!, completion: {
            result, error in
            SVProgressHUD.dismiss()
            if error == nil {
                
                self.attAccepted.on = ParseHelper.sharedInstance.currentUser!.attAccepted!
                self.newMessage.on = ParseHelper.sharedInstance.currentUser!.newMessage!
                
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }

    @IBAction func attAccepted(sender: AnyObject) {
        ParseHelper.sharedInstance.currentUser?.attAccepted = attAccepted.on
        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser, completion: nil)
    }
    
    @IBAction func newMessage(sender: AnyObject) {
        ParseHelper.sharedInstance.currentUser?.newMessage = newMessage.on
        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser, completion: nil)
    }
 }
