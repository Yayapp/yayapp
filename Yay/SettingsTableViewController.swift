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
        
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                
                self.attAccepted.on = PFUser.currentUser()!.objectForKey("attAccepted") as! Bool
            
                self.newMessage.on = PFUser.currentUser()!.objectForKey("newMessage") as! Bool
                
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }

    @IBAction func attAccepted(sender: AnyObject) {
        PFUser.currentUser()?.setObject(attAccepted.on, forKey: "attAccepted")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func newMessage(sender: AnyObject) {
        PFUser.currentUser()?.setObject(newMessage.on, forKey: "newMessage")
        PFUser.currentUser()?.saveInBackground()
    }
 }
