//
//  BlurryAlertViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 13.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class BlurryAlertViewController: UIViewController {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    static let BUTTON_OK = "okbutton"
    static let BUTTON_LOGIN = "loginbutton"
    
    var aboutText:String! = ""
    var messageText:String! = ""
    var action:String!

    
    @IBOutlet weak var about: UILabel!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var centerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        about.text = aboutText
        message.text = messageText
        
        centerButton.setImage(UIImage(named: action), forState: .Normal)
        
        centerButton.addTarget(self, action: Selector("\(action):"), forControlEvents: UIControlEvents.TouchUpInside)
        
            self.view.backgroundColor = UIColor.clearColor()
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            
            self.view.insertSubview(blurEffectView, atIndex: 0)
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func okbutton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func loginbutton(sender: AnyObject) {
        self.performSegueWithIdentifier("login", sender: nil)
//        let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
////        navigationController?.pushViewController(loginViewController, animated: true)
//        appDelegate.window?.navigationController!.pushViewController(loginViewController, animated: true)
    }

}
