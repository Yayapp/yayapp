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
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !requests.isEmpty {
            emptyView.hidden = true
            let tblView =  UIView(frame: CGRectZero)
            tableView.tableFooterView = tblView
            tableView.tableFooterView!.hidden = true
        }
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! RequestTableViewCell
        let request:Request! = requests[indexPath.row]
        
        request.event.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                cell.eventName.text = request.event.name
            } else {
                cell.eventName.text = ""
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
        request.attendee.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                cell.name.text = request.attendee.objectForKey("name") as! String!
                cell.avatar.file = request.attendee.objectForKey("avatar") as! PFFile!
                cell.avatar.loadInBackground()
            } else {
                cell.name.text = ""
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        cell.avatar.layer.borderColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1).CGColor
        cell.accept.tag = indexPath.row;
        cell.accept.addTarget(self, action: "accept:", forControlEvents: .TouchUpInside)
        
        cell.decline.tag = indexPath.row;
        cell.decline.addTarget(self, action: "decline:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let request:Request! = requests[indexPath.row]
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = request.attendee
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func accept(sender: AnyObject) {
        
        let request = requests[sender.tag]
        
        request.event.attendees.append(request.attendee)
        request.event.saveInBackground()
        request.accepted = true
        request.saveInBackground()
        requests.removeAtIndex(sender.tag)
        
        if request.event.conversation != nil {
            let query:LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
            query.predicate = LYRPredicate(property: "identifier", predicateOperator:LYRPredicateOperator.IsEqualTo, value:NSURL(string:request.event.conversation!))
            
            do {
                let conversation = try self.appDelegate.layerClient.executeQuery(query).firstObject as? LYRConversation
                let participants = NSMutableSet()
                participants.addObject(request.attendee.objectId!)
                try conversation!.addParticipants(participants as Set<NSObject>)
            } catch  {
                //
            }
        }
        if(request.event.attendees.count >= request.event.limit) {
            ParseHelper.declineRequests(request.event)
            ParseHelper.getOwnerRequests(PFUser.currentUser()!, block: {
                result, error in
                if (error == nil){
                    self.requests = result!
                    self.tableView.reloadData()
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else {
            tableView.reloadData()
        }
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
