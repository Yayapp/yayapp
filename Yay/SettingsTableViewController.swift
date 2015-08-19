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
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var distanceSlider: TTRangeSlider!
    @IBOutlet weak var attAccepted: UISwitch!
    
    @IBOutlet weak var eventNearby: UISwitch!
    @IBOutlet weak var eventsReminder: UISwitch!
    @IBOutlet weak var newMessage: UISwitch!
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        distanceSlider.delegate = self
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock({
            result, error in
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
        })
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        title = "Settings"
        navigationController?.navigationBar.topItem?.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func rangeSlider(sender:TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum:Float, andMaximumValue selectedMaximum:Float){
        distanceLabel.text = "\(Int(selectedMaximum)) km"
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock({
            result, error in
            PFUser.currentUser()?.setObject(Int(selectedMaximum), forKey: "distance")
            PFUser.currentUser()?.saveInBackground()
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
        PFUser.currentUser()?.setObject(0, forKey: "gender")
        PFUser.currentUser()?.saveInBackgroundWithBlock({
            result, error in
            self.maleButton.backgroundColor = UIColor(red:CGFloat(217/255.0), green:CGFloat(217/255.0), blue:CGFloat(217/255.0), alpha: 1)
            self.femaleButton.backgroundColor = UIColor(red:CGFloat(53/255.0), green:CGFloat(128/255.0), blue:CGFloat(184/255.0), alpha: 1)
        })
    }
    
    @IBAction func male(sender: AnyObject) {
        PFUser.currentUser()?.setObject(0, forKey: "gender")
        PFUser.currentUser()?.saveInBackgroundWithBlock({
            result, error in
            self.femaleButton.backgroundColor = UIColor(red:CGFloat(217/255.0), green:CGFloat(217/255.0), blue:CGFloat(217/255.0), alpha: 1)
            self.maleButton.backgroundColor = UIColor(red:CGFloat(53/255.0), green:CGFloat(128/255.0), blue:CGFloat(184/255.0), alpha: 1)
        })
    }
    
    @IBAction func logout(sender: AnyObject) {
        appDelegate.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError?) in
            if error == nil {
                PFUser.logOutInBackgroundWithBlock({
                    error in
                    if error == nil {
                        let startViewController = self.storyboard!.instantiateViewControllerWithIdentifier("StartViewController") as! StartViewController
                        self.navigationController!.popToRootViewControllerAnimated(false)
                        self.appDelegate.window!.rootViewController = startViewController
                        self.appDelegate.window!.makeKeyAndVisible()
                        
                    }
                })
                
            } else {
                println("Failed to deauthenticate: \(error)")
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red:CGFloat(236/255.0), green:CGFloat(242/255.0), blue:CGFloat(246/255.0), alpha: 1)
        header.textLabel.textAlignment = NSTextAlignment.Center
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(43)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else if section == 1{
            return 2
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 2 && indexPath.row == 2){
            deleteProfile()
        }
    }
    
    func deleteProfile(){
        let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_DELETE_PROFILE
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.aboutText = "PROFILE DELETION"
        blurryAlertViewController.messageText = "Are you sure you want to delete your profile?"
        self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
    }
    
    deinit {
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
    }
}
