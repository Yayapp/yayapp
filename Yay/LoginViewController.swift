//
//  ViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, InstagramDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

 
    @IBAction func facebookLogin(sender: AnyObject) {
        let permissions:[String] = ["email","user_about_me", "user_relationships", "user_birthday", "user_location"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                self.appDelegate.authenticateInLayer()
                Prefs.storeSessionId(user.sessionToken!)
                Prefs.storeLoginType(LoginType.FACEBOOK)
                
                if (FBSDKAccessToken.currentAccessToken() != nil){
                    
                    var userProfileRequestParams = [ "fields" : "id, name, email, picture, about"]
                    let userProfileRequest = FBSDKGraphRequest(graphPath: "me", parameters: userProfileRequestParams)
                    let graphConnection = FBSDKGraphRequestConnection()
                    graphConnection.addRequest(userProfileRequest, completionHandler: { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                        if(error != nil){
                            println(error)
                        }
                        else {
                            let fbEmail = result.objectForKey("email") as! String
                            let fbUserId = result.objectForKey("id") as! String
                            var url:NSURL = NSURL(string:"http://graph.facebook.com/\(fbUserId)/picture?width=150&height=150")!
                            var err: NSError?
                            var imageData :NSData = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
                            
                            var imageFile = PFFile(name: "image.jpg", data: imageData) as PFFile
                            
                            PFUser.currentUser()?.setObject(result.objectForKey("email")!, forKey: "email")
                            PFUser.currentUser()?.setObject(result.objectForKey("name")!, forKey: "name")
//                                PFUser.currentUser()?.setObject(result.objectForKey("about")?!, forKey: "about")
                      
                            PFUser.currentUser()?.setObject(imageFile, forKey: "avatar")
                            if user.isNew {
                                PFUser.currentUser()?.setObject(10, forKey: "distance")
                                PFUser.currentUser()?.setObject(1, forKey: "gender")
                                PFUser.currentUser()?.setObject(3, forKey: "invites")
                                PFUser.currentUser()?.setObject([], forKey: "interests")
                                PFUser.currentUser()?.setObject(true, forKey: "attAccepted")
                                PFUser.currentUser()?.setObject(true, forKey: "eventNearby")
                                PFUser.currentUser()?.setObject(true, forKey: "newMessage")
                                PFUser.currentUser()?.setObject(true, forKey: "eventsReminder")
                            } else {
                                self.performSegueWithIdentifier("proceed", sender: nil)
                            }
                            PFUser.currentUser()?.saveInBackgroundWithBlock({
                                result, error in
                                if error == nil {
                                    self.performSegueWithIdentifier("proceed", sender: nil)
                                }
                            })
                            
                        }
                    })
                    graphConnection.start()
                }
                
                
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
                 
                    PFUser.currentUser()?.setObject(true, forKey: "attAccepted")
                    PFUser.currentUser()?.setObject(true, forKey: "eventNearby")
                    PFUser.currentUser()?.setObject(true, forKey: "newMessage")
                    PFUser.currentUser()?.setObject([], forKey: "interests")
                    PFUser.currentUser()?.setObject(10, forKey: "distance")
                    PFUser.currentUser()?.setObject(1, forKey: "gender")
                    PFUser.currentUser()?.setObject(3, forKey: "invites")
                    PFUser.currentUser()?.setObject(true, forKey: "eventsReminder")
                    PFUser.currentUser()?.saveInBackgroundWithBlock({
                        result, error in
                        if error == nil {
                            self.performSegueWithIdentifier("proceed", sender: nil)
                        }
                    })
                    
                } else {
                    self.performSegueWithIdentifier("proceed", sender: nil)
                }
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
        
        PFUser.logInWithUsernameInBackground(user.username, password: "\(user.username.MD5())") {
            (pfuser: PFUser?, error: NSError?) -> Void in
            if pfuser != nil {
                self.appDelegate.authenticateInLayer()
                Prefs.storeSessionId(pfuser!.sessionToken!)
                Prefs.storeLoginType(LoginType.INSTAGRAM)
                self.performSegueWithIdentifier("proceed", sender: nil)
            } else {
                if(error!.code == 101) {
                    var pfuser = PFUser()
                    pfuser["name"] = user.fullName
                    pfuser["token"] = token
                    pfuser["distance"] = 10
                    pfuser["gender"] = 1
                    pfuser["interests"] = []
                    pfuser["attAccepted"] = true
                    pfuser["eventNearby"] = true
                    pfuser["newMessage"] = true
                    pfuser["invites"] = 3
                    pfuser["eventsReminder"] = true
                    pfuser.password = "\(user.username.MD5())"
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

