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
    var isLogin:Bool! = false
    
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var forgotPassword: UIButton!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var createEmailAccount: UIButton!
    
    @IBOutlet weak var orLabelBottomToEmailTextField: NSLayoutConstraint!
    @IBOutlet weak var orLabelBottomToEmailButton: NSLayoutConstraint!

    lazy var forgotPasswordAlert: UIAlertController = {
        var tField: UITextField!
        let alert = UIAlertController(title: "Reset password", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            if (!tField.text!.isEmpty && tField.text!.isEmail()) {
                PFUser.requestPasswordResetForEmailInBackground(tField.text!, block: {
                    result, error in
                    if(error == nil) {
                        MessageToUser.showMessage("Reset password", textId: "We've sent you password reset instructions. Please check your email.")
                    } else {
                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                    }
                })
            } else {
                MessageToUser.showDefaultErrorMessage("Please enter valid email")
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addTextFieldWithConfigurationHandler({(textField) in
            tField = textField
            tField.placeholder = "Email"
            tField.delegate = self
        })
        (alert.actions[0] as UIAlertAction).enabled = false

        return alert
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if (isLogin == true) {
            NSLayoutConstraint.activateConstraints([orLabelBottomToEmailTextField])
            NSLayoutConstraint.deactivateConstraints([orLabelBottomToEmailButton])

            textLabel.text = "Sign in with"
            createEmailAccount.hidden = true
            signIn.hidden = false
            email.hidden = false
            forgotPassword.hidden = false
            password.hidden = false
        } else {
            NSLayoutConstraint.activateConstraints([orLabelBottomToEmailButton])
            NSLayoutConstraint.deactivateConstraints([orLabelBottomToEmailTextField])

            textLabel.text = "Join with"
            createEmailAccount.hidden = false
            signIn.hidden = true
            email.hidden = true
            forgotPassword.hidden = true
            password.hidden = true
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if (isLogin == true) {
            NSLayoutConstraint.activateConstraints([orLabelBottomToEmailTextField])
            NSLayoutConstraint.deactivateConstraints([orLabelBottomToEmailButton])
        } else {
            NSLayoutConstraint.activateConstraints([orLabelBottomToEmailButton])
            NSLayoutConstraint.deactivateConstraints([orLabelBottomToEmailTextField])
        }
    }


    func proceed(){
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackground()
        self.performSegueWithIdentifier("proceed", sender: nil)
    }
   
    
    func setupDefaults(pfuser:PFUser){
        pfuser["distance"] = 20
        pfuser["gender"] = 1
        pfuser["attAccepted"] = true
        pfuser["eventNearby"] = true
        pfuser["newMessage"] = true
        pfuser["invites"] = 5
        pfuser["eventsReminder"] = true
    }
    
    func doRegistration(){
        
        setupDefaults(PFUser.currentUser()!)
        
        PFUser.currentUser()?.saveInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.proceed()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
 
    @IBAction func facebookLogin(sender: AnyObject) {
        let permissions:[String] = ["email","user_about_me", "user_relationships", "user_birthday", "user_location"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if error != nil {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
            }
            if let user = user {
                
                if (FBSDKAccessToken.currentAccessToken() != nil){
                    
                    let userProfileRequestParams = [ "fields" : "id, name, email, picture, about"]
                    let userProfileRequest = FBSDKGraphRequest(graphPath: "me", parameters: userProfileRequestParams)
                    let graphConnection = FBSDKGraphRequestConnection()
                    graphConnection.addRequest(userProfileRequest, completionHandler: { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                        if(error != nil){
                            print(error)
                        }
                        else {
                            PFUser.currentUser()?.setObject(result.objectForKey("email")!, forKey: "email")
                            PFUser.currentUser()?.setObject(result.objectForKey("name")!, forKey: "name")
                            
                            if user.isNew {
                                let fbUserId = result.objectForKey("id") as! String
                                let url:NSURL = NSURL(string:"https://graph.facebook.com/\(fbUserId)/picture?width=200&height=200")!
              
                                let URLRequestNeeded = NSURLRequest(URL: url)
                                NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {
                                    response,data, error in
                                    if error == nil {
                                        let picture = PFFile(name: "image.jpg", data: data!)
                                        PFUser.currentUser()!.setObject(picture!, forKey: "avatar")
                                        PFUser.currentUser()!.saveInBackground()
                                    }
                                    else {
                                        print("Error: \(error!.localizedDescription)")
                                    }
                                })
                          
                                self.doRegistration()
                            } else {
                                self.proceed()
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
            if error != nil {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
            }
            if let user = user {
                
                if user.isNew {
                    let url:NSURL = NSURL(string:"https://api.twitter.com/1.1/users/show.json?screen_name=\(PFTwitterUtils.twitter()!.screenName!)")!
                    let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
                    PFTwitterUtils.twitter()?.signRequest(request)
                    
                        do {
                            var response:NSURLResponse?
                            let data:NSData = try! NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                            
                            let result:NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.AllowFragments)) as! NSDictionary
                            let pictureUrl:NSURL = NSURL(string:result.objectForKey("profile_image_url_https") as! String)!
                            let imageData :NSData =  try NSData(contentsOfURL: pictureUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                            
                            let imageFile = PFFile(name: "image.jpg", data: imageData)
                            
                            PFUser.currentUser()?.setObject(imageFile!, forKey: "avatar")
                            PFUser.currentUser()?.setObject(result.objectForKey("name") as! String, forKey: "name")
                        } catch {
                            MessageToUser.showDefaultErrorMessage("Something went wrong")
                        }
                    
                    self.doRegistration()
                } else {
                    self.proceed()
                }
            }
        }
    }
//
    @IBAction func instagramLogin(sender: AnyObject) {
        guard let instagramView = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("InstagramViewController") as? InstagramViewController else {
            return
        }

        instagramView.delegate = self
        presentViewController(instagramView, animated: true, completion: nil)
    }
    
    func instagramSuccess(token:String, user:InstagramUser) {
        
        PFUser.logInWithUsernameInBackground(user.username, password: "\(user.username.MD5())") {
            (pfuser: PFUser?, error: NSError?) -> Void in
            if pfuser != nil {
                self.proceed()
            } else {
                if(error!.code == 101) {
                    let pfuser = PFUser()

                    if let profilePictureURL = user.profilePictureURL,
                        imageData: NSData = try? NSData(contentsOfURL: profilePictureURL, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
                        let imageFile = PFFile(name: "image.jpg", data: imageData)
                        pfuser["avatar"] = imageFile
                    }
                    
                    self.setupDefaults(pfuser)
                    pfuser["name"] = user.fullName
                    pfuser["token"] = token
                    pfuser.password = "\(user.username.MD5())"
                    pfuser.username = user.username
                    pfuser.signUpInBackgroundWithBlock {
                        (succeeded: Bool, error: NSError?) -> Void in
                        if error != nil {
                            MessageToUser.showDefaultErrorMessage("Something went wrong")
                        } else {
                            self.doRegistration()
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
    
    @IBAction func loginEmail(sender: AnyObject) {
        guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("CreateEmailAccountViewController") as? CreateEmailAccountViewController else {
            return
        }

        vc.isLogin = isLogin
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func signIn(sender: AnyObject) {
        self.view.endEditing(true)
        if (email.text!.isEmpty || password.text!.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign In.")
        } else if email.text!.isEmail() == false {
            MessageToUser.showDefaultErrorMessage("Email is invalid.")
        } else {
            PFUser.logInWithUsernameInBackground(email.text!, password:password.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
                    currentInstallation["user"] = PFUser.currentUser()
                    currentInstallation.saveInBackground()
                    
                    self.performSegueWithIdentifier("proceed", sender: nil)
                } else if(error!.code == 101) {
                    MessageToUser.showDefaultErrorMessage("Invalid email or password")
                } else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func forgotPassword(sender: AnyObject) {
        self.presentViewController(forgotPasswordAlert, animated: true, completion: nil)
    }

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        (forgotPasswordAlert.actions[0] as UIAlertAction).enabled = (!textField.text!.isEmpty && textField.text!.isEmail())
        
        return true
    }
}

