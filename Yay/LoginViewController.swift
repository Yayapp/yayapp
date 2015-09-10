//
//  ViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, InstagramDelegate, EnterCodeDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isLogin:Bool! = false
    
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
                let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
                currentInstallation["user"] = PFUser.currentUser()
                currentInstallation.saveInBackground()
                
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
                            
                            PFUser.currentUser()?.setObject(result.objectForKey("email")!, forKey: "email")
                            PFUser.currentUser()?.setObject(result.objectForKey("name")!, forKey: "name")
                            
                            if user.isNew {
                                let fbUserId = result.objectForKey("id") as! String
                                var url:NSURL = NSURL(string:"http://graph.facebook.com/\(fbUserId)/picture?width=200&height=200")!
                                var err: NSError?
                                var imageData :NSData = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
                                var imageFile = PFFile(name: "image.jpg", data: imageData) as PFFile
                                
                                PFUser.currentUser()?.setObject(imageFile, forKey: "avatar")
                                PFUser.currentUser()?.setObject(20, forKey: "distance")
                                PFUser.currentUser()?.setObject(1, forKey: "gender")
                                PFUser.currentUser()?.setObject(3, forKey: "invites")
                                PFUser.currentUser()?.setObject([], forKey: "interests")
                                PFUser.currentUser()?.setObject(true, forKey: "attAccepted")
                                PFUser.currentUser()?.setObject(true, forKey: "eventNearby")
                                PFUser.currentUser()?.setObject(true, forKey: "newMessage")
                                PFUser.currentUser()?.setObject(true, forKey: "eventsReminder")
                                PFUser.currentUser()?.saveInBackgroundWithBlock({
                                    result, error in
                                    if error == nil {
                                        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EnterCodeViewController") as! EnterCodeViewController
                                        vc.delegate = self
                                        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                                        self.presentViewController(vc, animated: true, completion: nil)
                                    } else {
                                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                                    }
                                })
                            } else {
                                PFUser.currentUser()?.saveInBackground()
                                self.appDelegate.authenticateInLayer()
                                self.performSegueWithIdentifier("proceed", sender: nil)
                            }
                            
                            
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
                
                let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
                currentInstallation["user"] = PFUser.currentUser()
                currentInstallation.saveInBackground()
                
                if user.isNew {
                    var url:NSURL = NSURL(string:"https://api.twitter.com/1.1/users/show.json?screen_name=\(PFTwitterUtils.twitter()!.screenName!)")!
                    var err: NSError?
                    let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                    PFTwitterUtils.twitter()?.signRequest(request)
                    var response:NSURLResponse?
                    let data:NSData = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&err)!
                    
                    if (error == nil){
                        let result:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments, error:&err) as! NSDictionary
                        var url:NSURL = NSURL(string:result.objectForKey("profile_image_url_https") as! String)!
                        var err: NSError?
                        var imageData :NSData = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
                        
                        var imageFile = PFFile(name: "image.jpg", data: imageData) as PFFile
                        
                        PFUser.currentUser()?.setObject(imageFile, forKey: "avatar")
                    }
                    
                    PFUser.currentUser()?.setObject(true, forKey: "attAccepted")
                    PFUser.currentUser()?.setObject(true, forKey: "eventNearby")
                    PFUser.currentUser()?.setObject(true, forKey: "newMessage")
                    PFUser.currentUser()?.setObject([], forKey: "interests")
                    PFUser.currentUser()?.setObject(20, forKey: "distance")
                    PFUser.currentUser()?.setObject(1, forKey: "gender")
                    PFUser.currentUser()?.setObject(3, forKey: "invites")
                    PFUser.currentUser()?.setObject(true, forKey: "eventsReminder")
                    
                    PFUser.currentUser()?.saveInBackgroundWithBlock({
                        result, error in
                        if error == nil {
                            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EnterCodeViewController") as! EnterCodeViewController
                            vc.delegate = self
                            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                            self.presentViewController(vc, animated: true, completion: nil)
                        } else {
                            MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                        }
                    })
                    
                } else {
                    PFUser.currentUser()?.saveInBackground()
                    self.appDelegate.authenticateInLayer()
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
                self.performSegueWithIdentifier("proceed", sender: nil)
            } else {
                if(error!.code == 101) {
                    var pfuser = PFUser()
                    
                    var err: NSError?
                    var imageData :NSData = NSData(contentsOfURL: user.profilePictureURL, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)!
                    var imageFile = PFFile(name: "image.jpg", data: imageData) as PFFile
                    
                    pfuser["avatar"] = imageFile
                    pfuser["name"] = user.fullName
                    pfuser["token"] = token
                    pfuser["distance"] = 20
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
                            MessageToUser.showDefaultErrorMessage("Something went wrong")
                        } else {
                            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EnterCodeViewController") as! EnterCodeViewController
                            vc.delegate = self
                            vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                            self.presentViewController(vc, animated: true, completion: nil)
                        }
                    }
                } else {
                    MessageToUser.showDefaultErrorMessage("Something went wrong")
                }
            }
        }
       
    }
    func instagramFailure() {
        MessageToUser.showDefaultErrorMessage("Something went wrong")
    }
    
    func validCode() {
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackground()
        
        self.appDelegate.authenticateInLayer()
        self.performSegueWithIdentifier("proceed", sender: nil)
    }
    
    @IBAction func loginEmail(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CreateEmailAccountViewController") as! CreateEmailAccountViewController
        vc.isLogin = isLogin
        presentViewController(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

