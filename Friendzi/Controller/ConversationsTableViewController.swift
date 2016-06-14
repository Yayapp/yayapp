//
//  ConversationsTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 06.10.15.
//  Copyright © 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class ConversationsTableViewController: UITableViewController {

    @IBOutlet private weak var emptyView: UIView?

    private var events:[Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(EventPhotoTableViewCell.nib, forCellReuseIdentifier: EventPhotoTableViewCell.reuseIdentifier)

        ParseHelper.getConversations(ParseHelper.sharedInstance.currentUser!, block: { result, error in
            if error == nil {
                self.events = result!
                self.tableView.reloadData()
                if !self.events.isEmpty {
                    self.emptyView?.hidden = true
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(EventPhotoTableViewCell.reuseIdentifier, forIndexPath: indexPath) as? EventPhotoTableViewCell else {
            return UITableViewCell()
        }

        cell.name?.text = events[indexPath.row].name

        if let photoURLString = events[indexPath.row].photo.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo?.sd_setImageWithURL(photoURL)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("messages", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "messages") {
            if let indexPath = sender as? NSIndexPath {
            let vc = (segue.destinationViewController as? MessagesTableViewController)
            vc?.event = events[indexPath.row]
            }
        }
    }
}
