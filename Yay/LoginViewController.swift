//
//  ViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
    @IBAction func facebookLogin(sender: AnyObject) {
        let permissions:[String] = ["user_about_me", "user_relationships", "user_birthday", "user_location"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                Prefs.storeSessionId(user.sessionToken!)
                Prefs.storeLoginType(LoginType.FACEBOOK)
                if user.isNew {
                    self.performSegueWithIdentifier("proceed", sender: nil)
                } else {
                    self.performSegueWithIdentifier("proceed", sender: nil)
                }
            } else {
                let alert = UIAlertView()
                alert.title = "Ooops"
                alert.message = error!.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
//                println("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }

    @IBAction func twitterLogin(sender: AnyObject) {
        PFTwitterUtils.logInWithBlock {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                Prefs.storeSessionId(user.sessionToken!)
                Prefs.storeLoginType(LoginType.TWITTER)
                if user.isNew {
                    self.performSegueWithIdentifier("proceed", sender: nil)
                } else {
                    self.performSegueWithIdentifier("proceed", sender: nil)
                }
            } else {
                let alert = UIAlertView()
                alert.title = "Ooops"
                alert.message = error!.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
//                println("Uh oh. The user cancelled the Twitter login.")
            }
        }
    }
}

