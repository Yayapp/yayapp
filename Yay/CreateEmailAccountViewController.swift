//
//  CreateEmailAccountViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit


class CreateEmailAccountViewController: KeyboardAnimationHelper {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isLogin:Bool! = false
   
    @IBOutlet var name: UITextField!
    
    @IBOutlet var email: UITextField!
    @IBOutlet var loginEmail: UITextField!
    
    @IBOutlet var email2: UITextField!
    @IBOutlet var loginPassword: UITextField!
    
    @IBOutlet var password1: UITextField!
    @IBOutlet var password2: UITextField!
    
    @IBOutlet var switchToLogin: UIButton!
    @IBOutlet var switchToRegister: UIButton!
    @IBOutlet var createAccount: UIButton!
    @IBOutlet var signIn: UIButton!
    @IBOutlet var accountExist: UILabel!
    @IBOutlet var forgotPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureTextFields([loginEmail, loginPassword, name, email, email2, password1, password2])

        if(isLogin == true){
            switchToLogin(true)
        } else {
            switchToRegister(true)
        }
    }
    
    func configureTextFields(textFields:[UITextField]){
        
        for textField in textFields {
            let paddingView = UIView(frame: CGRectMake(0, 0, 15, textField.frame.height))
            textField.leftView = paddingView
            textField.rightView = paddingView
            textField.leftViewMode = UITextFieldViewMode.Always
            textField.rightViewMode = UITextFieldViewMode.Always
            
            textField.delegate = self
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func createAccount(sender: AnyObject) {
        self.view.endEditing(true)
        if (name.text!.isEmpty || email.text!.isEmpty || password1.text!.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign Up.")
        } else if (email.text != email2.text) {
            MessageToUser.showDefaultErrorMessage("Emails are not same.")
        } else if (password1.text != password2.text) {
            MessageToUser.showDefaultErrorMessage("Passwords are not same.")
        } else if email.text!.isEmail() == false {
            MessageToUser.showDefaultErrorMessage("Email is invalid.")
        } else {
        
        let user = PFUser()
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
                self.proceed()
            }
        }
        }
    }

    @IBAction func signIn(sender: AnyObject) {
        self.view.endEditing(true)
        if (loginEmail.text!.isEmpty || loginPassword.text!.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign In.")
        } else if loginEmail.text!.isEmail() == false {
            MessageToUser.showDefaultErrorMessage("Email is invalid.")
        } else {
            PFUser.logInWithUsernameInBackground(loginEmail.text!, password:loginPassword.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
                    currentInstallation["user"] = PFUser.currentUser()
                    currentInstallation.saveInBackground()
                    
                    self.performSegueWithIdentifier("proceed", sender: nil)
                } else if(error!.code == 101) {
                    MessageToUser.showDefaultErrorMessage("Invalid username or password")
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
        let alert = UIAlertController(title: "Reset password", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Reset", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            if (!tField.text!.isEmpty && tField.text!.isEmail() == false) {
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
    
    func proceed() {
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation["user"] = PFUser.currentUser()
        currentInstallation.saveInBackground()
        
        self.performSegueWithIdentifier("proceedToPicker", sender: nil)
    }
}
