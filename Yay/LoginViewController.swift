//
//  ViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController, InstagramDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
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
                self.appDelegate.authenticateInLayer()
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
                self.appDelegate.authenticateInLayer()
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
//
    @IBAction func instagramLogin(sender: AnyObject) {
        let instagramView = self.storyboard!.instantiateViewControllerWithIdentifier("InstagramViewController") as! InstagramViewController
        instagramView.delegate = self
        presentViewController(instagramView, animated: true, completion: nil)
    }
    
    func instagramSuccess(token:String, user:InstagramUser) {
        
        PFUser.logInWithUsernameInBackground(user.username, password: "\(user.username.hash)") {
            (pfuser: PFUser?, error: NSError?) -> Void in
            if pfuser != nil {
                self.appDelegate.authenticateInLayer()
                Prefs.storeSessionId(pfuser!.sessionToken!)
                Prefs.storeLoginType(LoginType.INSTAGRAM)
                self.self.performSegueWithIdentifier("proceed", sender: nil)
            } else {
                if(error!.code == 101) {
                    var pfuser = PFUser()
                    pfuser["name"] = user.fullName
                    pfuser["token"] = token
                    pfuser.password = "\(user.username.hash)"
                    pfuser.username = user.username
                    pfuser.signUpInBackgroundWithBlock {
                        (succeeded: Bool, error: NSError?) -> Void in
                        if let error = error {
                            let alert = UIAlertView()
                            alert.title = "Ooops"
                            alert.message = "Something went wrong"
                            alert.addButtonWithTitle("OK")
                            alert.show()
                        } else {
                            self.appDelegate.authenticateInLayer()
                            self.performSegueWithIdentifier("proceed", sender: nil)
                        }
                    }
                } else {
                let alert = UIAlertView()
                alert.title = "Ooops"
                alert.message = "Something went wrong"
                alert.addButtonWithTitle("OK")
                alert.show()
                
                }
                
            }
        }
       
    }
    func instagramFailure() {
        let alert = UIAlertView()
        alert.title = "Ooops"
        alert.message = "Something went wrong"
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
}

