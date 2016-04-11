//
//  CreateEmailAccountViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class CreateEmailAccountViewController: UIViewController {
    @IBOutlet weak var keyboardAvoidingScrollView: TPKeyboardAvoidingScrollView!

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var isLogin:Bool! = false
   
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password1: UITextField!
    
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var createAccount: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
//        configureTextFields([email, password1, name, password2, password2])

    }
    
//    func configureTextFields(textFields:[UITextField]){
//        
//        for textField in textFields {
//            let paddingView = UIView(frame: CGRectMake(0, 0, 15, textField.frame.height))
//            textField.leftView = paddingView
//            textField.rightView = paddingView
//            textField.leftViewMode = UITextFieldViewMode.Always
//            textField.rightViewMode = UITextFieldViewMode.Always
//            
//            textField.delegate = self
//        }
//    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }


    //MARK: - Button Selectors
    @IBAction func createAccount(sender: AnyObject) {
        handleAccountCreation()
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
       
    func proceed() {
        if let currentInstallation = ParseHelper.sharedInstance.currentInstallation {
            currentInstallation.user = ParseHelper.sharedInstance.currentUser
            ParseHelper.saveObject(currentInstallation, completion: nil)
        }
        
        self.performSegueWithIdentifier("proceedToPicker", sender: nil)
    }

    func handleAccountCreation() {
        self.view.endEditing(true)
        if (name.text!.isEmpty || email.text!.isEmpty || password1.text!.isEmpty) {
            MessageToUser.showDefaultErrorMessage("Please fill all fields to Sign Up.")
        }  else if (password1.text != password2.text) {
            MessageToUser.showDefaultErrorMessage("Passwords are not same.")
        } else if email.text!.isEmail() == false {
            MessageToUser.showDefaultErrorMessage("Email is invalid.")
        } else {

            let user = PFUser()
            user["name"] = name.text
            user["distance"] = 20
            user["gender"] = 1
            user["attAccepted"] = true
            user["eventNearby"] = true
            user["newMessage"] = true
            user["eventsReminder"] = true
            user["invites"] = 5
            user.password = password2.text
            user.email = email.text
            user.username = email.text

            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    if error.code == 202 {
                        MessageToUser.showDefaultErrorMessage("Email \(user.email) already taken")
                    } else {
                        MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                    }
                } else {
                    self.proceed()
                }
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension CreateEmailAccountViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if password2 == textField {
            handleAccountCreation()
        } else {
            keyboardAvoidingScrollView.focusNextTextField()
        }

        return true
    }
}
