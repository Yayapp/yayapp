//
//  InviteViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 28.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import MessageUI
class InviteViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    var group:Category?
    var event:Event?
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
    }
    
    
    @IBAction func email(sender: AnyObject) {
        
            let mailComposeViewController = self.configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        
    }
    
    @IBAction func sms(sender: AnyObject) {
        
            if (self.canSendText()) {
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = self.configuredMessageComposeViewController()
                
                // Present the configured MFMessageComposeViewController instance
                // Note that the dismissal of the VC will be handled by the messageComposer instance,
                // since it implements the appropriate delegate call-back
                self.presentViewController(messageComposeVC, animated: true, completion: nil)
            } else {
                // Let the user know if his/her device isn't able to send text messages
                let errorAlert = UIAlertView(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", delegate: self, cancelButtonTitle: "OK")
                errorAlert.show()
            }
    }
    
    @IBAction func more(sender: AnyObject) {
        var textToShare = ""
        
        if event != nil {
            textToShare = "Hi, please check this happening \"\(event!.name)\" on \(dateFormatter.stringFromDate(event!.startDate)).\n\nhttp://friendzi.io/"
        } else {
            textToShare = "Hi, please check this group \"\(group!.name)\".\n\nhttp://friendzi.io/"
        }
        
        if let myWebsite = NSURL(string: "http://friendzi.io/") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeMail, UIActivityTypeMessage]
            //
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let userName = PFUser.currentUser()?.objectForKey("name") as! String
        var emailTitle:String = ""
        var messageBody:String = ""
        
        if event != nil {
            emailTitle = "\(userName) shared happening from Friendzi app"
            messageBody = "Hi, please check this happening \"\(event!.name)\" on \(dateFormatter.stringFromDate(event!.startDate)).\n\nhttp://friendzi.io/"
        } else {
            emailTitle = "\(userName) shared group from Friendzi app"
            messageBody = "Hi, please check this group \"\(group!.name)\".\n\nhttp://friendzi.io/"
        }
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject(emailTitle)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        if event != nil {
            messageComposeVC.body = "Hi, please check this happening \"\(event!.name)\" on \(dateFormatter.stringFromDate(event!.startDate)).\n\nhttp://friendzi.io/"
        } else {
            messageComposeVC.body = "Hi, please check this group \"\(group!.name)\".\n\nhttp://friendzi.io/"
        }
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}