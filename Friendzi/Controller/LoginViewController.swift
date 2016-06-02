//
//  ViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 Nerses Zakoyan. All rights reserved.
//

import UIKit
import InstagramKit
import SVProgressHUD
import ParseTwitterUtils
import ParseFacebookUtilsV4

final class LoginViewController: UIViewController, InstagramDelegate {

    @IBOutlet private weak var signIn: UIButton?
    @IBOutlet private weak var forgotPassword: UIButton?
    @IBOutlet private weak var password: UITextField?
    @IBOutlet private weak var email: UITextField?
    @IBOutlet private weak var textLabel: UILabel?
    @IBOutlet private weak var createEmailAccount: UIButton?
    @IBOutlet private weak var orLabelBottomToEmailTextField: NSLayoutConstraint?
    @IBOutlet private weak var orLabelBottomToEmailButton: NSLayoutConstraint?

    private let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    private lazy var forgotPasswordAlert: UIAlertController = {
        var tField: UITextField!
        let alert = UIAlertController(title: "Reset password".localized, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reset".localized, style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            if (!tField.text!.isEmpty && tField.text!.isEmail()) {
                ParseHelper.requestPasswordResetForEmail(tField.text!, completion: {
                    result, error in
                    if(error == nil) {
                        MessageToUser.showMessage("Reset password", textId: "We've sent you password reset instructions. Please check your email.".localized)
                    } else {
                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                    }
                })
            } else {
                MessageToUser.showDefaultErrorMessage("Please enter valid email".localized)
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Default, handler: nil))
        alert.addTextFieldWithConfigurationHandler({(textField) in
            tField = textField
            tField.placeholder = "Email".localized
            tField.delegate = self
        })
        (alert.actions[0] as UIAlertAction).enabled = false

        return alert
    }()

    var isLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let orLabelBottomToEmailTextField = orLabelBottomToEmailTextField, let orLabelBottomToEmailButton = orLabelBottomToEmailButton else {
            return
        }

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
            self.performSegueWithIdentifier("proceed".localized, sender: nil)
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
                
                if (FBSDKAccessToken.currentAccessToken() != nil) {
                    
                    let userProfileRequestParams = [ "fields" : "id, gender, name, email, picture, about"]
                    let userProfileRequest = FBSDKGraphRequest(graphPath: "me", parameters: userProfileRequestParams)
                    let graphConnection = FBSDKGraphRequestConnection()
                    graphConnection.addRequest(userProfileRequest, completionHandler: { (connection: FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in

                        if(error != nil){
                            SVProgressHUD.dismiss()
                            print(error)
                        } else {
                            ParseHelper.sharedInstance.currentUser?.email = result.objectForKey("email")! as? String
                            ParseHelper.sharedInstance.currentUser?.name = result.objectForKey("name")! as? String
                            ParseHelper.sharedInstance.currentUser?.gender = (result.objectForKey("gender ")! as? String)?.lowercaseString == "male" ? 1 : 0

                            let fbUserId = result.objectForKey("id") as! String
                            let url: NSURL = NSURL(string:"https://graph.facebook.com/\(fbUserId)/picture?width=200&height=200")!
                            let URLRequestNeeded = NSURLRequest(URL: url)
                            NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: { response, data, error in
                                if error == nil {
                                    let picture = PFFile(name: "image.jpg", data: data!)
                                    ParseHelper.sharedInstance.currentUser!.avatar = File(parseFile: picture!)
                                    ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser!, completion: nil)
                                } else {
                                    SVProgressHUD.dismiss()
                                    print("Error: \(error!.localizedDescription)")
                                }

                                if user.isNew {
                                    DataProxy.sharedInstance.setNeedsShowAllHints(true)
                                    self.doRegistration()

                                } else {
                                    self.proceed()
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
                            MessageToUser.showDefaultErrorMessage("Something went wrong".localized)
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
                            MessageToUser.showDefaultErrorMessage("Something went wrong".localized)
                        } else {
                            self.proceed()
                        }
                    })
                } else {
                    SVProgressHUD.dismiss()
                    MessageToUser.showDefaultErrorMessage("Something went wrong".localized)

                    return
                }
            } else if pfuser != nil {
                self.proceed()
            }
        })
    }
    
    func instagramFailure() {
        MessageToUser.showDefaultErrorMessage("Something went wrong".localized)
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
        guard let email = email?.text, let password = password?.text else {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign In.".localized)
            return
        }

        if (email.isEmpty || password.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign In.".localized)
       
        } else if email.isEmail() == false {
            MessageToUser.showDefaultErrorMessage("Email is invalid.".localized)
        
        } else {
            SVProgressHUD.show()
            ParseHelper.logInWithUsernameInBackground(email, password: password, completion: { (user: User?, error: NSError?) in
                SVProgressHUD.dismiss()

                if user != nil {
                    if let currentInstallation = ParseHelper.sharedInstance.currentInstallation,
                    currentUser = ParseHelper.sharedInstance.currentUser {
                        currentInstallation.user = currentUser
                        ParseHelper.saveObject(ParseHelper.sharedInstance.currentInstallation, completion: nil)
                    }
                    self.proceed()
                } else if(error!.code == 101) {
                    SVProgressHUD.dismiss()
                    MessageToUser.showDefaultErrorMessage("Invalid email or password".localized)
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

private extension LoginViewController {
    //MARK:- UI Setup
    func setupView() {
        guard let orLabelBottomToEmailTextField = orLabelBottomToEmailTextField, let orLabelBottomToEmailButton = orLabelBottomToEmailButton else {
            return
        }

        if (isLogin == true) {

            NSLayoutConstraint.activateConstraints([orLabelBottomToEmailTextField])
            NSLayoutConstraint.deactivateConstraints([orLabelBottomToEmailButton])

            textLabel?.text = "Sign in with"
            createEmailAccount?.hidden = true
            signIn?.hidden = false
            email?.hidden = false
            forgotPassword?.hidden = false
            password?.hidden = false
       
        } else {
            NSLayoutConstraint.activateConstraints([orLabelBottomToEmailButton])
            NSLayoutConstraint.deactivateConstraints([orLabelBottomToEmailTextField])

            textLabel?.text = "Join with"
            createEmailAccount?.hidden = false
            signIn?.hidden = true
            email?.hidden = true
            forgotPassword?.hidden = true
            password?.hidden = true
        }

        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
