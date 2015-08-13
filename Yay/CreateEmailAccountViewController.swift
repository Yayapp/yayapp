//
//  CreateEmailAccountViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit


class CreateEmailAccountViewController: UIViewController, UITextFieldDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var animateDistance:CGFloat = 0.0
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var email2: UITextField!
    @IBOutlet weak var password1: UITextField!
    
    @IBOutlet weak var password2: UITextField!
    
    @IBOutlet weak var switchToLogin: UIButton!
    @IBOutlet weak var switchToRegister: UIButton!
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var accountExist: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        name.delegate = self
        email.delegate = self
        email2.delegate = self
        password1.delegate = self
        password2.delegate = self
        switchToRegister(true)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createAccount(sender: AnyObject) {
        if !email.text.isEmpty && PatternValidator.validate(email.text, patternString: PatternValidator.EMAIL_PATTERN) && email.text == email2.text && !password1.text.isEmpty && password1.text == password2.text {
            
        var user = PFUser()
        user["name"] = name.text
        user["interests"] = []
        user["distance"] = 10
        user["gender"] = 1
        user["attAccepted"] = true
        user["eventNearby"] = true
        user["newMessage"] = true
        user.password = password2.text
        user.email = email.text
        user.username = email.text
            
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                let alert = UIAlertView()
                alert.title = "Ooops"
                alert.message = error.localizedDescription
                alert.addButtonWithTitle("OK")
                alert.show()
            } else {
                self.appDelegate.authenticateInLayer()
                self.performSegueWithIdentifier("proceed", sender: nil)
            }
        }
        }
    }

    @IBAction func signIn(sender: AnyObject) {
        if !email.text.isEmpty && PatternValidator.validate(email.text, patternString: PatternValidator.EMAIL_PATTERN) && !password1.text.isEmpty {
            PFUser.logInWithUsernameInBackground(email.text, password:password1.text) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    self.appDelegate.authenticateInLayer()
                    Prefs.storeSessionId(user!.sessionToken!)
                    Prefs.storeLoginType(LoginType.MAIL)
                    self.performSegueWithIdentifier("proceed", sender: nil)
                } else {
                    let alert = UIAlertView()
                    alert.title = "Ooops"
                    alert.message = error?.localizedDescription
                    alert.addButtonWithTitle("OK")
                    alert.show()
                }
            }
        }
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func switchToRegister(sender: AnyObject) {
        switchToRegister.hidden = true
        switchToLogin.hidden = false
        signIn.hidden = true
        createAccount.hidden = false
        name.hidden = false
        password2.hidden = false
        email2.hidden = false
        accountExist.text = "Already have an account?"
    }

    @IBAction func switchToLogin(sender: AnyObject) {
        switchToRegister.hidden = false
        switchToLogin.hidden = true
        signIn.hidden = false
        createAccount.hidden = true
        name.hidden = true
        password2.hidden = true
        email2.hidden = true
        accountExist.text = "Don't have an account?"
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
