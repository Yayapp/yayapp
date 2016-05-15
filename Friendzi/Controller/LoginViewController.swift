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
                ParseHelper.requestPasswordResetForEmail(tField.text!, completion: {
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
        SVProgressHUD.dismiss()

        if let currentInstallation = ParseHelper.sharedInstance.currentInstallation,
        currentUser = ParseHelper.sharedInstance.currentUser {
            currentInstallation.user = currentUser
            ParseHelper.saveObject(currentInstallation, completion: nil)
        }

        if ParseHelper.sharedInstance.currentUser?.location == nil {
            self.performSegueWithIdentifier("proceed", sender: nil)
        } else {
            self.appDelegate.gotoMainTabBarScreen()
        }
    }
   
    
    func setupDefaults(user: User){
        user.distance = 20
        user.gender = 1
        user.attAccepted = true
        user.eventNearby = true
        user.newMessage = true
        user.invites = 5
        user.eventsReminder = true
    }
    
    func doRegistration(){
        
        setupDefaults(ParseHelper.sharedInstance.currentUser!)

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }

        ParseHelper.saveObject(currentUser, completion: {
            result, error in
            if error == nil {
                self.proceed()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
 
    @IBAction func facebookLogin(sender: AnyObject) {
        SVProgressHUD.show()

        let permissions:[String] = ["email","user_about_me", "user_relationships", "user_birthday", "user_location"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            
            if error != nil {
                SVProgressHUD.dismiss()
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                return
            }

            if let user = user {
                
                if (FBSDKAccessToken.currentAccessToken() != nil){
                    
                    let userProfileRequestParams = [ "fields" : "id, name, email, picture, about"]
                    let userProfileRequest = FBSDKGraphRequest(graphPath: "me", parameters: userProfileRequestParams)
                    let graphConnection = FBSDKGraphRequestConnection()
                    graphConnection.addRequest(userProfileRequest, completionHandler: { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in

                        if(error != nil){
                            SVProgressHUD.dismiss()
                            print(error)
                        }
                        else {
                            ParseHelper.sharedInstance.currentUser?.email = result.objectForKey("email")! as? String
                            ParseHelper.sharedInstance.currentUser?.name = result.objectForKey("name")! as? String
                            
                            if user.isNew {
                                DataProxy.sharedInstance.setNeedsShowAllHints(true)

                                let fbUserId = result.objectForKey("id") as! String
                                let url:NSURL = NSURL(string:"https://graph.facebook.com/\(fbUserId)/picture?width=200&height=200")!
              
                                let URLRequestNeeded = NSURLRequest(URL: url)
                                NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {
                                    response,data, error in
                                    if error == nil {
                                        let picture = PFFile(name: "image.jpg", data: data!)
                                        ParseHelper.sharedInstance.currentUser!.avatar = File(parseFile: picture!)
                                        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser!, completion: nil)
                                    }
                                    else {
                                        SVProgressHUD.dismiss()
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
                    DataProxy.sharedInstance.setNeedsShowAllHints(true)

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

                            ParseHelper.sharedInstance.currentUser?.avatar = File(parseFile: imageFile!)
                            ParseHelper.sharedInstance.currentUser?.name = result.objectForKey("name") as? String
                            ParseHelper.sharedInstance.currentUser?.about = result.objectForKey("description") as? String
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
        SVProgressHUD.show()

        ParseHelper.logInWithUsernameInBackground(user.username, password: "\(user.username.MD5())", completion: {
            (pfuser: User?, error: NSError?) -> Void in
            if error != nil {
                if(error!.code == 101) {
                    DataProxy.sharedInstance.setNeedsShowAllHints(true)

                    let pfuser = User()

                    if let profilePictureURL = user.profilePictureURL,
                        imageData: NSData = try? NSData(contentsOfURL: profilePictureURL, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
                        if let imageFile = PFFile(name: "image.jpg", data: imageData) {
                            pfuser.avatar = File(parseFile: imageFile)
                        }
                    }
                    
                    self.setupDefaults(pfuser)
                    pfuser.name = user.fullName
                    pfuser.about = user.bio
                    pfuser.token = token
                    pfuser.password = "\(user.username.MD5())"
                    pfuser.username = user.username

                    ParseHelper.signUpInBackgroundWithBlock(pfuser, completion: {
                        (succeeded: Bool?, error: NSError?) -> Void in
                        SVProgressHUD.dismiss()

                        if error != nil {
                            MessageToUser.showDefaultErrorMessage("Something went wrong")
                        } else {
                            self.proceed()
                        }
                    })
                } else {
                    SVProgressHUD.dismiss()
                    MessageToUser.showDefaultErrorMessage("Something went wrong")

                    return
                }
            } else if pfuser != nil {
                self.proceed()
            }
        })
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
            SVProgressHUD.show()
            ParseHelper.logInWithUsernameInBackground(email.text!, password:password.text!, completion: { (user: User?, error: NSError?) in
                SVProgressHUD.dismiss()

                if user != nil {
                    if let currentInstallation = ParseHelper.sharedInstance.currentInstallation,
                    currentUser = ParseHelper.sharedInstance.currentUser {
                        currentInstallation.user = currentUser
                        ParseHelper.saveObject(ParseHelper.sharedInstance.currentInstallation, completion: nil)
                    }
                    if user?.location == nil {
                    self.performSegueWithIdentifier("proceed", sender: nil)
                    } else {
                        self.appDelegate.gotoMainTabBarScreen()
                    }
                } else if(error!.code == 101) {
                    SVProgressHUD.dismiss()
                    MessageToUser.showDefaultErrorMessage("Invalid email or password")
                } else {
                    SVProgressHUD.dismiss()
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                }
            })
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

