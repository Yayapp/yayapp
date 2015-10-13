//
//  PhotosTableViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 01.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

protocol ChooseCategoryPhotoDelegate : NSObjectProtocol {
    func madeCategoryPhotoChoice(eventPhoto: EventPhoto)
}

class PhotosTableViewController: UITableViewController {

    var eventPhotos:[EventPhoto] = []
    var category:Category!
    var delegate:ChooseCategoryPhotoDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        ParseHelper.getEventPhotos(category, block: {
            result, error in
            if error == nil {
                self.eventPhotos = result!
                self.tableView.reloadData()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventPhotos.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.madeCategoryPhotoChoice(eventPhotos[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let eventPhoto = eventPhotos[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventPhotoTableViewCell

        cell.photo.file = eventPhoto.photo
        cell.photo.loadInBackground()
        
        return cell
    }

    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}

