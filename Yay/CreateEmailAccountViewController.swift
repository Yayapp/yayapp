//
//  CreateEmailAccountViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit


class CreateEmailAccountViewController: UIViewController, UITextFieldDelegate, EnterCodeDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isLogin:Bool! = false
    var animateDistance:CGFloat = 0.0
   
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var loginEmail: UITextField!
    
    @IBOutlet weak var email2: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBOutlet weak var password1: UITextField!
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var switchToLogin: UIButton!
    @IBOutlet weak var switchToRegister: UIButton!
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var accountExist: UILabel!
    @IBOutlet weak var forgotPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loginEmail.delegate = self
        loginPassword.delegate = self
        name.delegate = self
        email.delegate = self
        email2.delegate = self
        password1.delegate = self
        password2.delegate = self
        if(isLogin == true){
            switchToLogin(true)
        } else {
            switchToRegister(true)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createAccount(sender: AnyObject) {
        self.view.endEditing(true)
        if (name.text.isEmpty || email.text.isEmpty || password1.text.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign Up.")
        } else if (email.text != email2.text) {
            MessageToUser.showDefaultErrorMessage("Emails are not same.")
        } else if (password1.text != password2.text) {
            MessageToUser.showDefaultErrorMessage("Passwords are not same.")
        } else if !PatternValidator.validate(email.text, patternString: PatternValidator.EMAIL_PATTERN) {
            MessageToUser.showDefaultErrorMessage("Email is invalid.")
        } else {
        
        var user = PFUser()
        user["name"] = name.text
        user["interests"] = []
        user["distance"] = 20
        user["gender"] = 1
        user["attAccepted"] = true
        user["eventNearby"] = true
        user["newMessage"] = true
        user["eventsReminder"] = true
        user["invites"] = 3
        user.password = password2.text
        user.email = email.text
        user.username = email.text
            
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                MessageToUser.showDefaultErrorMessage(error.localizedDescription)
            } else {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("EnterCodeViewController") as! EnterCodeViewController
                vc.delegate = self
                vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        }
    }

    @IBAction func signIn(sender: AnyObject) {
        self.view.endEditing(true)
        if (loginEmail.text.isEmpty || loginPassword.text.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign In.")
        } else if !PatternValidator.validate(loginEmail.text, patternString: PatternValidator.EMAIL_PATTERN) {
            MessageToUser.showDefaultErrorMessage("Email is invalid.")
        } else {
            PFUser.logInWithUsernameInBackground(loginEmail.text, password:loginPassword.text) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
                    currentInstallation["user"] = PFUser.currentUser()
                    currentInstallation.saveInBackground()
                    
                    self.appDelegate.authenticateInLayer()
                    self.performSegueWithIdentifier("proceed", sender: nil)
                } else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func forgotPassword(sender: AnyObject) {
        var tField: UITextField!
        var alert = UIAlertController(title: "Reset password", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction!) in
            if (!tField.text.isEmpty && PatternValidator.validate(tField.text, patternString: PatternValidator.EMAIL_PATTERN)) {
                PFUser.requestPasswordResetForEmailInBackground(tField.text, block: {
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
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func switchToRegister(sender: AnyObject) {
        switchToRegister.hidden = true
        switchToLogin.hidden = false
        signIn.hidden = true
        createAccount.hidden = false
        name.hidden = false
        password1.hidden = false
        password2.hidden = false
        forgotPassword.hidden = true
        loginEmail.hidden = true
        loginPassword.hidden = true
        email.hidden = false
        email2.hidden = false
        accountExist.text = "Already have an account?"
    }

    @IBAction func switchToLogin(sender: AnyObject) {
        switchToRegister.hidden = false
        switchToLogin.hidden = true
        signIn.hidden = false
        createAccount.hidden = true
        name.hidden = true
        forgotPassword.hidden = false
        password1.hidden = true
        password2.hidden = true
        loginEmail.hidden = false
        loginPassword.hidden = false
        email.hidden = true
        email2.hidden = true
        accountExist.text = "Don't have an account?"
    }
    
    
    func validCode() {
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackground()
        
        self.appDelegate.authenticateInLayer()
        self.performSegueWithIdentifier("proceedToPicker", sender: nil)
    }
    
    
    struct MoveKeyboard {
        static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
        static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2;
        static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8;
        static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 216;
        static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 162;
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let textFieldRect : CGRect = self.view.window!.convertRect(textField.bounds, fromView: textField)
        let viewRect : CGRect = self.view.window!.convertRect(self.view.bounds, fromView: self.view)
        
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }


}
