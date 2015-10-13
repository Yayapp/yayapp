//
//  SettingsTableViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import Darwin

class SettingsTableViewController: UITableViewController, TTRangeSliderDelegate {

    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var distanceSlider: TTRangeSlider!
    @IBOutlet var attAccepted: UISwitch!
    
    @IBOutlet var eventNearby: UISwitch!
    @IBOutlet var eventsReminder: UISwitch!
    @IBOutlet var newMessage: UISwitch!
    
    @IBOutlet var maleButton: UIButton!
    
    @IBOutlet var femaleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        let tblView =  UIView(frame: CGRectZero)
        tableView.tableFooterView = tblView
        tableView.tableFooterView!.hidden = true
        
        
        let logout = UIBarButtonItem(image:UIImage(named: "logout"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logout:"))
        logout.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setRightBarButtonItem(logout, animated: false)
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        distanceSlider.delegate = self
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                let selectedMaximum = PFUser.currentUser()!.objectForKey("distance") as! Float
                self.distanceLabel.text = "\(Int(selectedMaximum)) km"
                self.distanceSlider.selectedMaximum = selectedMaximum
                self.attAccepted.on = PFUser.currentUser()!.objectForKey("attAccepted") as! Bool
                self.eventNearby.on = PFUser.currentUser()!.objectForKey("eventNearby") as! Bool
                self.newMessage.on = PFUser.currentUser()!.objectForKey("newMessage") as! Bool
                self.eventsReminder.on = PFUser.currentUser()!.objectForKey("eventsReminder") as! Bool
                if(PFUser.currentUser()!.objectForKey("gender") as! Int == 0) {
                    self.female(true)
                } else {
                    self.male(true)
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }

    func rangeSlider(sender:TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum:Float, andMaximumValue selectedMaximum:Float){
        distanceLabel.text = "\(Int(selectedMaximum))KM"
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                PFUser.currentUser()?.setObject(Int(selectedMaximum), forKey: "distance")
                PFUser.currentUser()?.saveInBackground()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
    }

    @IBAction func attAccepted(sender: AnyObject) {
        PFUser.currentUser()?.setObject(attAccepted.on, forKey: "attAccepted")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func eventNearby(sender: AnyObject) {
        PFUser.currentUser()?.setObject(eventNearby.on, forKey: "eventNearby")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func eventsReminder(sender: AnyObject) {
        PFUser.currentUser()?.setObject(eventsReminder.on, forKey: "eventsReminder")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func newMessage(sender: AnyObject) {
        PFUser.currentUser()?.setObject(newMessage.on, forKey: "newMessage")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func female(sender: AnyObject) {
        self.maleButton.backgroundColor = Color.GenderInactiveColor
        self.femaleButton.backgroundColor = Color.GenderActiveColor
        PFUser.currentUser()?.setObject(0, forKey: "gender")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func male(sender: AnyObject) {
        self.femaleButton.backgroundColor = Color.GenderInactiveColor
        self.maleButton.backgroundColor = Color.GenderActiveColor
        PFUser.currentUser()?.setObject(1, forKey: "gender")
        PFUser.currentUser()?.saveInBackground()
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock({
                    error in
                    if error == nil {
                        let startViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StartViewController") as! StartViewController
                        self.navigationController!.popToRootViewControllerAnimated(false)
                        self.appDelegate.window!.rootViewController = startViewController
                        self.appDelegate.window!.makeKeyAndVisible()
                        
                    }
                })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = Color.SettingsHeader
        header.textLabel!.textAlignment = NSTextAlignment.Center
        header.textLabel!.textColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(43)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 2
        }
    }
    
    @IBAction func deleteProfile(){
        let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_DELETE
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.aboutText = "Sorry, are you sure you want to delete your profile?"
        blurryAlertViewController.messageText = "You'll need another invite to start a new profile again."
        blurryAlertViewController.hasCancelAction = true
        self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
  
    deinit {
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
    }
}
