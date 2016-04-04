//
//  RecentViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 10.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
class RecentViewController: UITableViewController {
    
    var notifications:[Notification] = []
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(RequestTableViewCell.nib, forCellReuseIdentifier: RequestTableViewCell.reuseIdentifier)

        guard let currentUser = PFUser.currentUser() else {
            return
        }
        
        ParseHelper.getRecentRequests(currentUser, block: { [weak self] result, error in
            guard error == nil else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)

                return
            }

            guard let result = result else {
                return
            }

            self?.notifications = result.map({$0 as Notification})
            self?.tableView.reloadData()
        })
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(RequestTableViewCell.reuseIdentifier) as? RequestTableViewCell else {
            return UITableViewCell()
        }

        let notification:Notification! = notifications[indexPath.row]
        
        cell.name.text = notification.getTitle()
        cell.eventName.text = notification.getText()

        if let photoURLString = notification.getPhoto().url,
            photoURL = NSURL(string: photoURLString) {
            cell.avatar.sd_setImageWithURL(photoURL)
        }
        
        cell.avatar.layer.borderColor = Color.PrimaryActiveColor.CGColor
        if (notification.isDecidable() || notification.isKindOfClass(Message)){
            cell.avatar.tag = indexPath.row;
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("goToProfile:"))
            cell.avatar.addGestureRecognizer(tapGestureRecognizer)
        }
        
        if (notification.isKindOfClass(Request) && notification.isDecidable()){
            cell.accept.tag = indexPath.row;
            cell.accept.addTarget(self, action: "accept:", forControlEvents: .TouchUpInside)
            
            cell.decline.tag = indexPath.row;
            cell.decline.addTarget(self, action: "decline:", forControlEvents: .TouchUpInside)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        if (notification.isSelectable()){
            if notification.isKindOfClass(Request){
                if (notification as! Request).event != nil {
                    guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("EventDetailsViewController") as? EventDetailsViewController else {
                        return
                    }

                    vc.event = (notification as! Request).event
                    navigationController?.pushViewController(vc, animated: true)
                } else {
                    guard let vc = UIStoryboard.groupsTab()?.instantiateViewControllerWithIdentifier("GroupDetailsViewController") as? GroupDetailsViewController else {
                        return
                    }
                    
                    vc.group = (notification as! Request).group
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("MessagesTableViewController") as? MessagesTableViewController else {
                    return
                }

                vc.event = (notification as! Message).event
                navigationController?.pushViewController(vc, animated: true)
            }
            
            
        }
    }
    
    @IBAction func goToProfile(sender: AnyObject) {
        
        guard let vc = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }
        
        if(notifications[sender.tag].isKindOfClass(Message)){
            let notification = notifications[sender.tag] as! Message
            vc.user = notification.user
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let notification = notifications[sender.tag] as! Request
            vc.user = notification.attendee
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func accept(sender: AnyObject) {
        
        let request = notifications[sender.tag] as! Request
        
        if (request.event != nil) {
            request.event!.attendees.append(request.attendee)
            request.event!.saveInBackground()
            request.accepted = true
            request.saveInBackgroundWithBlock({
                done in
                self.notifications.removeAtIndex(sender.tag)
                UIApplication.sharedApplication().applicationIconBadgeNumber-=1
                
                if(request.event!.attendees.count >= request.event!.limit) {
                    ParseHelper.declineRequests(request.event!)
                    self.notifications = self.notifications.filter({$0.isKindOfClass(Request) && ($0 as! Request).event != nil && ($0 as! Request).event!.objectId != request.event!.objectId})
                }
                //            self.appDelegate.leftViewController.requestsCountLabel.text = "\(self.requests.count)"
                self.tableView.reloadData()
            })
        } else {
            request.group!.attendees.append(request.attendee)
            request.group!.saveInBackground()
            request.accepted = true
            request.saveInBackgroundWithBlock({
                done in
                self.notifications.removeAtIndex(sender.tag)
                UIApplication.sharedApplication().applicationIconBadgeNumber-=1
                
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func decline(sender: AnyObject) {
        let request = notifications[sender.tag] as! Request
        request.accepted = false
        request.saveInBackground()
        UIApplication.sharedApplication().applicationIconBadgeNumber-=1
        notifications.removeAtIndex(sender.tag)
        //        self.appDelegate.leftViewController.requestsCountLabel.text = "\(self.requests.count)"
        tableView.reloadData()
    }
}