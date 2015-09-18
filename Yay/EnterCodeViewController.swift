//
//  EnterCodeViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 02.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit
import Darwin

class EnterCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var code1: UITextField!
    @IBOutlet weak var code2: UITextField!
    @IBOutlet weak var code3: UITextField!
    @IBOutlet weak var code4: UITextField!
    @IBOutlet weak var code5: UITextField!
    
    var delegate:EnterCodeDelegate!
    
    var fields:[UITextField]=[]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fields = [code1, code2, code3, code4, code5]

        code1.delegate = self
        code2.delegate = self
        code3.delegate = self
        code4.delegate = self
        code5.delegate = self
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        self.view.insertSubview(blurEffectView, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func apply(sender: AnyObject) {
        let code = code1.text! + code2.text! + code3.text! + code4.text! + code5.text!
        ParseHelper.getInviteCode(code, block: {
            result, error in
            if (error == nil){
                if !result!.isEmpty {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true, forKey: "hasPermission")
                    defaults.synchronize()
                    
                    let invitationCode = result!.first!
                    
                    if ((invitationCode.invited+1) >= invitationCode.limit) {
                        invitationCode.delete()
                    } else {
                        invitationCode.invited += 1
                        invitationCode.saveInBackground()
                    }
                    self.dismissViewControllerAnimated(true, completion: {
                        self.delegate.validCode()
                    })
                } else {
                    let sendMailErrorAlert = UIAlertView(title: "Invitation code", message: "Invitation code is not valid.", delegate: self, cancelButtonTitle: "OK")
                    sendMailErrorAlert.show()
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
    
    @IBAction func quit(sender: AnyObject) {
        PFUser.currentUser()?.deleteInBackground()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if fields.indexOf(textField) == 4 {
            textField.resignFirstResponder()
        } else {
            fields[fields.indexOf(textField)!+1].becomeFirstResponder()
        }
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (range.length + range.location >= 1 && !string.isEmpty) {
            textFieldShouldReturn(textField)
            if (fields.indexOf(textField)!<4) {
                fields[fields.indexOf(textField)!+1].text = string
            }
            return false;
        }
//        
//        if (range.length + range.location > count(textField.text) )
//        {
//            return false;
//        }
//       
        
        let newLength = textField.text!.characters.count + string.characters.count - range.length
        return newLength <= 1
    }

}
protocol EnterCodeDelegate : NSObjectProtocol {
    func validCode()
}