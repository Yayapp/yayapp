//
//  RecentViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 10.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import SVProgressHUD

final class RecentViewController: UITableViewController {

    private var notifications:[Notification] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(RequestTableViewCell.nib, forCellReuseIdentifier: RequestTableViewCell.reuseIdentifier)

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
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
        //TODO:- The hole logic needs to be refactored
        guard let cell = tableView.dequeueReusableCellWithIdentifier(RequestTableViewCell.reuseIdentifier) as? RequestTableViewCell else {
            return UITableViewCell()
        }

        let notification = notifications[indexPath.row]
        cell.name?.text = notification.getTitle()
        cell.eventName?.text = notification.getText()

        if let photoURLString = notification.getPhoto().url, photoURL = NSURL(string: photoURLString) {
            cell.avatar?.sd_setImageWithURL(photoURL)
        }

        cell.avatar?.layer.borderColor = Color.PrimaryActiveColor.CGColor

        if notification is Message {
            cell.avatar?.tag = indexPath.row;
            let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(RecentViewController.goToProfile(_:)))
            cell.avatar?.addGestureRecognizer(tapGestureRecognizer)
        }

        if let request = notification as? Request {
            if notification.isDecidable() {
                if request.accepted == false {
                    cell.accept?.hidden = false
                    cell.accept?.setImage(UIImage(named: "createevent_button"), forState: .Normal)
                    cell.accept?.tag = indexPath.row
                    cell.accept?.addTarget(self, action: #selector(RecentViewController.accept(_:)), forControlEvents: .TouchUpInside)

                    cell.decline?.hidden = false
                    cell.decline?.setImage(UIImage(named: "cancelevent_button"), forState: .Normal)
                    cell.decline?.tag = indexPath.row
                    cell.decline?.addTarget(self, action: #selector(RecentViewController.decline(_:)), forControlEvents: .TouchUpInside)
                } else {
                    cell.accept?.hidden = false
                    cell.accept?.setImage(UIImage(named: "accept"), forState: .Normal)
                    cell.accept?.tag = indexPath.row
                    cell.decline?.hidden = true
                }

            } else {
                cell.decline?.hidden = true
                cell.accept?.setImage(UIImage(named: request.accepted == true ? "accept" : "requestRejected"), forState: .Normal)
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        if (notification.isSelectable()){
            if notification is Request {
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
        
        if(notifications[sender.tag] is Message){
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
        SVProgressHUD.show()
        let request = notifications[sender.tag] as! Request
        if (request.event != nil) {
            request.event!.attendeeIDs.append(request.attendee.objectId!)
            ParseHelper.saveObject(request.event, completion: nil)
            request.accepted = true
            ParseHelper.saveObject(request, completion: { done in
                SVProgressHUD.dismiss()
                self.notifications.removeAtIndex(sender.tag)
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
                if(request.event?.attendeeIDs.count >= request.event?.limit) {
                    ParseHelper.declineRequests(request.event!)
                    self.notifications = self.notifications.filter({$0 is Request && ($0 as! Request).event != nil && ($0 as! Request).event?.objectId != request.event?.objectId})
                }
                self.tableView.reloadData()
            })

        } else {
            request.group!.attendeeIDs.append(request.attendee.objectId!)
            ParseHelper.saveObject(request.group!, completion: nil)
            request.accepted = true
            ParseHelper.saveObject(request, completion: { done in
                self.notifications.removeAtIndex(sender.tag)
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
                self.tableView.reloadData()
            })
        }
    }

    @IBAction func decline(sender: AnyObject) {
        let request = notifications[sender.tag] as! Request
        request.accepted = false
        SVProgressHUD.show()
        ParseHelper.saveObject(request) { success, error in
            SVProgressHUD.dismiss()
            if let success = success where success == true {
                UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
                self.notifications.removeAtIndex(sender.tag)
                self.tableView.reloadData()
            } else {
                if let error = error {
                    UIAlertController.showSimpleAlertViewWithText(error.localizedDescription,
                                                                  title: "Error".localized,
                                                                  controller: self,
                                                                  completion: nil,
                                                                  alertHandler: nil)
                }
            }
        }
    }
}