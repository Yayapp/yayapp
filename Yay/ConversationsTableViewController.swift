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
    
    @IBOutlet var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Messages"
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
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
        let vc:MessagesTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessagesTableViewController") as! MessagesTableViewController
        vc.event = events[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
