//
//  ConversationsTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class ConversationsTableViewController: UITableViewController {
    
    var events:[Event] = []
    
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ParseHelper.getConversations(PFUser.currentUser()!, block: {
            result, error in
            if error == nil {
                self.events = result!
                self.tableView.reloadData()
                if !self.events.isEmpty {
                    self.emptyView.hidden = true
                    let tblView =  UIView(frame: CGRectZero)
                    self.tableView.tableFooterView = tblView
                    self.tableView.tableFooterView!.hidden = true
                }
            } else {
                MessageToUser.showDefaultErrorMessage("Something went wrong.")
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventPhotoTableViewCell
        cell.name.text = events[indexPath.row].name
        cell.photo.file = events[indexPath.row].photo
        cell.photo.loadInBackground()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("messages", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "messages") {
            if let indexPath = sender as? NSIndexPath {
            let vc = (segue.destinationViewController as! MessagesTableViewController)
            vc.event = events[indexPath.row]
            }
        }
    }
}
