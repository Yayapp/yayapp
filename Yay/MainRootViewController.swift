//
//  MainViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MessageUI

class MainRootViewController: UIViewController, ChooseCategoryDelegate, MFMailComposeViewControllerDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var rightSwitchBarButtonItem:UIBarButtonItem?
    
    var thisWeekCenter:NSLayoutConstraint!
    var todayCenter:NSLayoutConstraint!
    var inviteCode:InviteCode?
    
    
    @IBOutlet weak var today: UIButton!
    @IBOutlet weak var tomorrow: UIButton!
    @IBOutlet weak var thisWeek: UIButton!
    
    @IBOutlet weak var todayUnderline: UIView!
    @IBOutlet weak var tomorrowUnderline: UIView!
    @IBOutlet weak var thisWeekUnderline: UIView!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var createEvent: UIButton!
    
    var currentVC:UIViewController!
    var isMapView = false
    var eventsData:[Event]!=[]
    var chosenCategories:[Category] = []
    var selectedSegment:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if (PFUser.currentUser() != nil) {
            createEvent.hidden = false
        }
        
        rightSwitchBarButtonItem = UIBarButtonItem(image:UIImage(named: "mapmarkerico"), style: UIBarButtonItemStyle.Plain, target: self, action: "switchTapped:")
        rightSwitchBarButtonItem!.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        
        self.navigationItem.setRightBarButtonItem(rightSwitchBarButtonItem, animated: true)

        today(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func segmentChanged() {
        var vc:EventsViewController
        if (isMapView) {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapEventsViewController") as! MapEventsViewController
        } else {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
        }
        if(selectedSegment == 0) {
            ParseHelper.getTodayEvents(PFUser.currentUser(), categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        } else if (selectedSegment == 1) {
            ParseHelper.getTomorrowEvents(PFUser.currentUser(), categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        } else {
            ParseHelper.getThisWeekEvents(PFUser.currentUser(), categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        }
        
        updateActiveViewController(vc)
    }
    
    @IBAction func today(sender: AnyObject) {
        selectedSegment = 0
        todayUnderline.hidden = false
        tomorrowUnderline.hidden = true
        thisWeekUnderline.hidden = true
        today.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        tomorrow.titleLabel?.font = UIFont.systemFontOfSize(15)
        thisWeek.titleLabel?.font = UIFont.systemFontOfSize(15)
        segmentChanged()
    }
    
    @IBAction func tomorrow(sender: AnyObject) {
        selectedSegment = 1
        todayUnderline.hidden = true
        tomorrowUnderline.hidden = false
        thisWeekUnderline.hidden = true
        today.titleLabel?.font = UIFont.systemFontOfSize(15)
        tomorrow.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        thisWeek.titleLabel?.font = UIFont.systemFontOfSize(15)
        segmentChanged()
    }
    
    @IBAction func thisWeek(sender: AnyObject) {
        selectedSegment = 2
        todayUnderline.hidden = true
        tomorrowUnderline.hidden = true
        thisWeekUnderline.hidden = false
        today.titleLabel?.font = UIFont.systemFontOfSize(15)
        tomorrow.titleLabel?.font = UIFont.systemFontOfSize(15)
        thisWeek.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        segmentChanged()
    }
  
    
    func showMessages() {
        let controller: ConversationListViewController = ConversationListViewController(layerClient: appDelegate.layerClient)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func showProfile(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        vc.user = PFUser.currentUser()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSettings(){
        performSegueWithIdentifier("settings", sender: nil)
    }
    
    func showInvite(){
        if((PFUser.currentUser()?.objectForKey("invites") as! Int)>0){
            if MFMailComposeViewController.canSendMail() {
                randomString({
                    code in
                    let inviteACL:PFACL = PFACL()
                    inviteACL.setPublicWriteAccess(true)
                    inviteACL.setPublicReadAccess(true)
                    self.inviteCode = InviteCode()
                    self.inviteCode!.code = code
                    self.inviteCode!.limit = 1
                    self.inviteCode!.ACL = inviteACL
                    self.inviteCode!.invited = 0
                    self.inviteCode!.saveInBackground()
                    let mailComposeViewController = self.configuredMailComposeViewController(code)
                    self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                })
            } else {
                self.showSendMailErrorAlert()
            }
        } else {
            let sendMailErrorAlert = UIAlertView(title: "Invite friend", message: "You have no more invites.", delegate: self, cancelButtonTitle: "OK")
            sendMailErrorAlert.show()
        }
    }
    
    func configuredMailComposeViewController(code:String) -> MFMailComposeViewController {
        let userName = PFUser.currentUser()?.objectForKey("name") as! String
        var emailTitle = "\(userName) invited you to Friendzi app"
        var messageBody = "Hi, use this code \(code) to enter the app.\n\nhttp://friendzy.io/"
        
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
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if result.value != MFMailComposeResultSent.value {
            inviteCode?.deleteInBackground()
            inviteCode = nil
        } else {
            PFUser.currentUser()?.incrementKey("invites", byAmount: -1)
            PFUser.currentUser()?.saveInBackground()
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showRequests(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("RequestsTableViewController") as! RequestsTableViewController
        ParseHelper.getOwnerRequests(PFUser.currentUser()!, block: {
            result, error in
            if (error == nil){
                vc.requests = result!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
    }
    
    func showHappenings(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("HappeningsViewController") as! HappeningsViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showTerms(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TermsController") as! TermsController
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func showPrivacy(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PrivacyPolicyController") as! PrivacyPolicyController
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func openCategoryPicker(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseCategoryViewController") as! ChooseCategoryViewController
        vc.delegate = self
        vc.selectedCategoriesData = chosenCategories
        vc.multi = true
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func madeCategoryChoice(categories: [Category]) {
        chosenCategories = categories
        segmentChanged()
    }
    
    func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    func updateActiveViewController(activeViewController: UIViewController?) {
        if activeViewController != nil {
            addChildViewController(activeViewController!)
            activeViewController!.view.frame = container.bounds
            container.addSubview(activeViewController!.view)
            activeViewController!.didMoveToParentViewController(self)
            
        }
        removeInactiveViewController(currentVC)
        currentVC = activeViewController
    }

    func switchTapped(sender:UIButton) {
        isMapView = !isMapView
        if isMapView {
            rightSwitchBarButtonItem!.image = UIImage(named: "listico")
        } else {
            rightSwitchBarButtonItem!.image = UIImage(named: "mapmarkerico")
        }
        segmentChanged()
    }
   
    let letters = Array("abcdefghijklmnopqrstuvwxyz0123456789")
    
    func randomString(blockResult:((String!) -> Void)?) {
    
        let randomString:NSMutableString = NSMutableString(capacity: 5)
    
        for i in 1...5 {
            randomString.appendString("\(letters[Int(arc4random_uniform(36))])")
        }
        
        ParseHelper.checkIfCodeExist(randomString as String, block: {
            result, error in
            if result != nil {
                if (result == true) {
                    self.randomString(blockResult)
                } else {
                    blockResult!(randomString as String)
                }
            }
        })
    
    }
    

}
