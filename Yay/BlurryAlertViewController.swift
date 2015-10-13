//
//  BlurryAlertViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 13.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit
import Darwin

class BlurryAlertViewController: UIViewController {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    static let BUTTON_OK = "okbutton"
    static let BUTTON_DELETE = "deletebutton"
    
    var aboutText:String! = ""
    var messageText:String! = ""
    var action:String!
    var hasCancelAction:Bool = false
    var event:Event?
    var completion:(()->Void)?
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var about: UILabel!
    
    @IBOutlet var message: UILabel!
    
    @IBOutlet var centerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        about.text = aboutText
        message.text = messageText
        
        cancel.hidden = !hasCancelAction
        
        centerButton.setImage(UIImage(named: action), forState: .Normal)
        
        centerButton.addTarget(self, action: Selector("\(action):"), forControlEvents: UIControlEvents.TouchUpInside)
        
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            self.view.insertSubview(blurEffectView, atIndex: 0)
       
    }


    @IBAction func okbutton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func deletebutton(sender: AnyObject) {
        if event != nil {
            event?.deleteInBackgroundWithBlock({
                result, error in
                if error == nil {
                    if result == true {
                        self.dismissViewControllerAnimated(true, completion:self.completion!)
                    } else {
                        MessageToUser.showDefaultErrorMessage("Couldn't remove the event")
                    }
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else {
            ParseHelper.removeUserEvents(PFUser.currentUser()!, block: {
                result, error in
                if error == nil {
                    PFUser.currentUser()?.deleteInBackgroundWithBlock({
                        result, error in
                        if error == nil {
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setBool(false, forKey: "hasPermission")
                            defaults.synchronize()
                            exit(0)
                        } else {
                            MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                        }
                    })
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
    }
}
