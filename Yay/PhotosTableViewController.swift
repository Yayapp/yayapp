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

        ParseHelper.getEventPhotos(category) { [weak self] (photos, error) in
            guard let photos = photos
                where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
            }
            
            self?.eventPhotos = photos
            self?.tableView .reloadData()
        }

        tableView.registerNib(EventPhotoTableViewCell.flatNib, forCellReuseIdentifier: EventPhotoTableViewCell.flatReuseIdentifier)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventPhotos.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/3
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.madeCategoryPhotoChoice((eventPhotos)[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(EventPhotoTableViewCell.flatReuseIdentifier, forIndexPath: indexPath) as? EventPhotoTableViewCell else {
            return UITableViewCell()
        }

        let eventPhoto = eventPhotos[indexPath.row]

        if let photoURLString = eventPhoto.photo.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo?.sd_setImageWithURL(photoURL)
        }
        
        return cell
    }

}

