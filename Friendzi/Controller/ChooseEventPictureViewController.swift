//
//  ChooseEventPictureViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

protocol ChooseEventPictureDelegate : NSObjectProtocol {
    func madeEventPictureChoice(photo: File, pickedPhoto: UIImage?)
}

final class ChooseEventPictureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseCategoryPhotoDelegate {
    
    @IBOutlet private weak var photos: UITableView?

    private let picker = UIImagePickerController()
    private var contentDataSource = [String : [EventPhoto]]()

    weak var delegate: ChooseEventPictureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        photos?.registerNib(EventPhotoTableViewCell.flatNib, forCellReuseIdentifier: EventPhotoTableViewCell.flatReuseIdentifier)
        photos?.delegate = self
        photos?.dataSource = self

        ParseHelper.getEventPhotos { [weak self] eventPhotos, error in
            guard let eventPhotos = eventPhotos where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
            }

            for eventPhoto in eventPhotos {
                if self?.contentDataSource.keys.contains(eventPhoto.name) == true {
                    self?.contentDataSource[eventPhoto.name]?.append(eventPhoto)
                } else {
                    self?.contentDataSource[eventPhoto.name] = [eventPhoto]
                }
            }

            self?.photos?.reloadData()
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentDataSource.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = photos?.dequeueReusableCellWithIdentifier(EventPhotoTableViewCell.flatReuseIdentifier, forIndexPath: indexPath) as? EventPhotoTableViewCell else {
            return UITableViewCell()
        }

        let key = Array(contentDataSource.keys)[indexPath.row]

        guard let eventPhoto = contentDataSource[key]?.first else {
            return cell
        }

        cell.name?.text = eventPhoto.name

        if let photoURLString = eventPhoto.photo.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo?.sd_setImageWithURL(photoURL)
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let key = Array(contentDataSource.keys)[indexPath.row]

        guard let  vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("PhotosTableViewController") as? PhotosTableViewController,
            eventPhotos = contentDataSource[key] else {
                return
        }

        vc.delegate = self
        vc.eventPhotos = eventPhotos
        
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height / 2
    }

    func madeCategoryPhotoChoice(eventPhoto: EventPhoto) {
        delegate?.madeEventPictureChoice(eventPhoto.photo, pickedPhoto: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func library(sender: AnyObject) {
        presentImagePickerSheet()
    }

    func presentImagePickerSheet() {
        let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = .Camera
            self.picker.cameraCaptureMode = .Photo
            self.picker.showsCameraControls = true;
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Library", style: .Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = .PhotoLibrary
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = (info[UIImagePickerControllerEditedImage] as! UIImage).resizeToDefault()
        let imageData = UIImageJPEGRepresentation(pickedImage, 70)
        let imageFile = File(data: imageData!)!
        delegate?.madeEventPictureChoice(imageFile, pickedPhoto: pickedImage)
        dismissViewControllerAnimated(true, completion: {
            self.navigationController?.popViewControllerAnimated(true)
        }) //5
        
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

