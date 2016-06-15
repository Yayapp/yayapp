//
//  SettingsTableViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

final class SettingsTableViewController: UITableViewController {

    @IBOutlet private weak var attAccepted: UISwitch?
    @IBOutlet private weak var newMessage: UISwitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            UIAlertController.showSimpleAlertViewWithText("It seems like you are out of sync. Please log out and log in again".localized,
                                                          title: "Out of sync".localized,
                                                          controller: self,
                                                          completion: nil,
                                                          alertHandler: nil)
            return
        }

        ParseHelper.fetchObject(currentUser, completion: { result, error in
            SVProgressHUD.dismiss()
            if error == nil {
                if let attAccepted = currentUser.attAccepted {
                    self.attAccepted?.on = attAccepted
                }

                if let newMessage = ParseHelper.sharedInstance.currentUser?.newMessage {
                    self.attAccepted?.on = newMessage
                }

            } else {
                if let error = error {
                    MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                }
            }
        })
    }

    @IBAction func attAccepted(sender: AnyObject) {
        ParseHelper.sharedInstance.currentUser?.attAccepted = attAccepted?.on
        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser, completion: nil)
    }
    
    @IBAction func newMessage(sender: AnyObject) {
        ParseHelper.sharedInstance.currentUser?.newMessage = newMessage?.on
        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser, completion: nil)
    }
 }
