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

class PhotosTableViewController: PFQueryTableViewController {

    var eventPhotos:[EventPhoto] = []
    var category:Category!
    var delegate:ChooseCategoryPhotoDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className:EventPhoto.parseClassName())
        query.whereKey("category", equalTo: category)
        return query
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/3
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.madeCategoryPhotoChoice((objects as! [EventPhoto])[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell {
        
        let eventPhoto = object as! EventPhoto
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! EventPhotoTableViewCell

        cell.photo.file = eventPhoto.photo
        cell.photo.loadInBackground()
        
        return cell
    }

}

