//
//  SettingsTableViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, TTRangeSliderDelegate {

    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var distanceSlider: TTRangeSlider!
    @IBOutlet weak var attAccepted: UISwitch!
    
    @IBOutlet weak var eventNearby: UISwitch!
    @IBOutlet weak var newMessage: UISwitch!
    
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
        })
        
        
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
    
    @IBAction func newMessage(sender: AnyObject) {
        PFUser.currentUser()?.setObject(newMessage.on, forKey: "newMessage")
        PFUser.currentUser()?.saveInBackground()
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
            return 3
        } else if section == 1{
            return 2
        } else {
            return 1
        }
    }
    deinit {
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
    }
}
