//
//  RequestsTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class RequestsTableViewController: UITableViewController {
    
    var requests:[Request] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! RequestTableViewCell
        let request:Request! = requests[indexPath.row]
        request.attendee.fetchIfNeededInBackgroundWithBlock({
            result, error in
            cell.name.text = request.attendee.objectForKey("name") as! String
            cell.avatar.file = request.attendee.objectForKey("avatar") as! PFFile
            cell.avatar.loadInBackground()
        })
        
        cell.accept.tag = indexPath.row;
        cell.accept.addTarget(self, action: "accept:", forControlEvents: .TouchUpInside)
        
        cell.decline.tag = indexPath.row;
        cell.decline.addTarget(self, action: "decline:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBAction func accept(sender: AnyObject) {
        let request = requests[sender.tag]
        request.event.attendees.append(request.attendee)
        request.event.saveInBackground()
        request.accepted = true
        request.saveInBackground()
        requests.removeAtIndex(sender.tag)
        tableView.reloadData()
    }
    
    @IBAction func decline(sender: AnyObject) {
        let request = requests[sender.tag]
        request.accepted = false
        request.saveInBackground()
        requests.removeAtIndex(sender.tag)
        tableView.reloadData()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
