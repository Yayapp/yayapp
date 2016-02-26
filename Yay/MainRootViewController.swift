//
//  MainViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MessageUI

class MainRootViewController: UIViewController, MFMailComposeViewControllerDelegate, EventCreationDelegate, ListEventsDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var rightSwitchBarButtonItem:UIBarButtonItem?
    
    @IBOutlet weak var today: UIButton!
    @IBOutlet weak var tomorrow: UIButton!
    @IBOutlet weak var thisWeek: UIButton!
    
    @IBOutlet weak var todayUnderline: UIView!
    @IBOutlet weak var tomorrowUnderline: UIView!
    @IBOutlet weak var thisWeekUnderline: UIView!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var createEvent: UIButton!
    
    var currentVC:EventsViewController!
    var isMapView = false
    var eventsData:[Event]!=[]
    var chosenCategories:[Category] = []
    var selectedSegment:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image : UIImage = UIImage(named: "logo")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        self.navigationItem.titleView = imageView
    }
    
    override func viewWillAppear(animated: Bool) {
        today(true)
    }

    
    override func viewDidAppear(animated: Bool) {
        
        if Prefs.getPref(Prefs.tut) == false {
            Prefs.setPref(Prefs.tut)
     
            
        }
        
        
    }
    

    func segmentChanged() {
        var vc:EventsViewController
        if (isMapView) {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapEventsViewController") as! MapEventsViewController
        } else {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
        }
        vc.delegate = self
        if(selectedSegment == 0) {
            ParseHelper.getTodayEvents(PFUser.currentUser(), categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else if (selectedSegment == 1) {
            ParseHelper.getTomorrowEvents(PFUser.currentUser(), categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else {
            ParseHelper.getThisWeekEvents(PFUser.currentUser(), categories: chosenCategories, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
        
        updateActiveViewController(vc)
    }
    
    @IBAction func createEvent(sender: AnyObject) {
        if PFUser.currentUser() != nil {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CreateEventViewController") as! CreateEventViewController
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func eventCreated(event:Event) {
        segmentChanged()
    }
    
    @IBAction func today(sender: AnyObject) {
        selectedSegment = 0
        todayUnderline.hidden = false
        tomorrowUnderline.hidden = true
        thisWeekUnderline.hidden = true

        today.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        tomorrow.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        thisWeek.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        segmentChanged()
    }
    
    @IBAction func tomorrow(sender: AnyObject) {
        selectedSegment = 1
        todayUnderline.hidden = true
        tomorrowUnderline.hidden = false
        thisWeekUnderline.hidden = true
        
        today.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        tomorrow.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        thisWeek.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        

        segmentChanged()
    }
    
    @IBAction func thisWeek(sender: AnyObject) {
        selectedSegment = 2
        todayUnderline.hidden = true
        tomorrowUnderline.hidden = true
        thisWeekUnderline.hidden = false
        today.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        tomorrow.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        thisWeek.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
//        today.titleLabel?.font = UIFont.systemFontOfSize(15)
//        tomorrow.titleLabel?.font = UIFont.systemFontOfSize(15)
//        thisWeek.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        segmentChanged()
    }
  
    
    func showMessages() {
        let controller: ConversationsTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ConversationsTableViewController") as! ConversationsTableViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func showProfile(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        vc.user = PFUser.currentUser()
        navigationController?.pushViewController(vc, animated: true)
    }

    
    func showInvite(){
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = self.configuredMailComposeViewController()
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let userName = PFUser.currentUser()?.objectForKey("name") as! String
        let emailTitle = "\(userName) invited you to Friendzi app"
        let messageBody = "\(userName) has invited you to join Friendzi. \n\nhttp://friendzi.io/"
        
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
    
//    func showHappenings(){
//        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("HappeningsViewController") as! HappeningsViewController
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func showTerms(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("TermsController") as! TermsController
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func showPrivacy(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("PrivacyPolicyController") as! PrivacyPolicyController
        presentViewController(vc, animated: true, completion: nil)
    }
    func madeEventChoice(event: Event) {
        performSegueWithIdentifier("event_details", sender: event)
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
    
    func updateActiveViewController(activeViewController: EventsViewController!) {
        if activeViewController != nil {
            addChildViewController(activeViewController!)
            activeViewController!.view.frame = container.bounds
            container.addSubview(activeViewController!.view)
            activeViewController!.didMoveToParentViewController(self)
            
        }
        removeInactiveViewController(currentVC)
        currentVC = activeViewController
    }
    
    
    @IBAction func switchTapped(sender: AnyObject) {
        isMapView = !isMapView
        if isMapView {
            navigationItem.rightBarButtonItem!.image = UIImage(named: "listico")
        } else {
            navigationItem.rightBarButtonItem!.image = UIImage(named: "mapmarkerico")
        }
        segmentChanged()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "event_details") {
            if let event = sender as? Event {
                let vc = (segue.destinationViewController as! EventDetailsViewController)
                vc.event = event
                vc.delegate = currentVC
            }
        }
    }

}
