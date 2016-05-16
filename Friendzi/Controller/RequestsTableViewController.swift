//
//  RequestsTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class RequestsTableViewController: UITableViewController {

    @IBOutlet private weak var emptyView: UIView!

    private var requests:[Request] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(RequestTableViewCell.nib, forCellReuseIdentifier: RequestTableViewCell.reuseIdentifier)
        ParseHelper.getOwnerRequests(ParseHelper.sharedInstance.currentUser!, block: {
            result, error in
            if (error == nil){
                self.requests = result!
                if !self.requests.isEmpty {
                    self.emptyView.hidden = true
                    let tblView =  UIView(frame: CGRectZero)
                    self.tableView.tableFooterView = tblView
                    self.tableView.tableFooterView!.hidden = true
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(RequestTableViewCell.reuseIdentifier) as? RequestTableViewCell else {
            return UITableViewCell()
        }

        let request:Request! = requests[indexPath.row]

        ParseHelper.fetchObject(request.event!, completion: {
            result, error in
            if error == nil {
                cell.eventName.text = request.event!.name
            } else {
                cell.eventName.text = ""
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })

        ParseHelper.fetchObject(request.attendee, completion: {
            result, error in
            if error == nil {
                cell.name.text = request.attendee.name

                if let avatarFile = request.attendee.avatar,
                    photoURLString = avatarFile.url,
                    photoURL = NSURL(string: photoURLString) {
                    cell.avatar.sd_setImageWithURL(photoURL)
                }

            } else {
                cell.name.text = ""
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        cell.avatar.layer.borderColor = Color.PrimaryActiveColor.CGColor
        cell.accept.tag = indexPath.row;
        cell.accept.addTarget(self, action: #selector(RequestsTableViewController.accept(_:)), forControlEvents: .TouchUpInside)
        cell.decline.tag = indexPath.row;
        cell.decline.addTarget(self, action: #selector(RequestsTableViewController.decline(_:)), forControlEvents: .TouchUpInside)

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let request:Request! = requests[indexPath.row]
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        userProfileViewController.user = request.attendee
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func accept(sender: AnyObject) {
        let request = requests[sender.tag]
        guard let attendeeId = request.attendee.objectId else {
            return
        }

        request.event!.attendeeIDs.append(attendeeId)
        ParseHelper.saveObject(request.event!, completion: nil)
        request.accepted = true
        ParseHelper.saveObject(request, completion: {
            done in
            self.requests.removeAtIndex(sender.tag)
            UIApplication.sharedApplication().applicationIconBadgeNumber-=1
            
            if(request.event!.attendeeIDs.count >= request.event!.limit) {
                ParseHelper.declineRequests(request.event!)
                self.requests = self.requests.filter({$0.event!.objectId != request.event!.objectId})
            }
            self.tableView.reloadData()
        })
    }

    @IBAction func decline(sender: AnyObject) {
        let request = requests[sender.tag]
        request.accepted = false
        ParseHelper.saveObject(request, completion: nil)
        UIApplication.sharedApplication().applicationIconBadgeNumber-=1
        requests.removeAtIndex(sender.tag)
        tableView.reloadData()
    }
}
