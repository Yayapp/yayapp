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

class ChooseEventPictureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseCategoryPhotoDelegate {

    let picker = UIImagePickerController()
    var delegate:ChooseEventPictureDelegate!
    var categories:[Category]! = []
    var fetchingDataIndexPath: NSIndexPath?
    
    @IBOutlet weak var photos: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        photos.registerNib(EventPhotoTableViewCell.flatNib, forCellReuseIdentifier: EventPhotoTableViewCell.flatReuseIdentifier)
        photos.delegate = self
        photos.dataSource = self
        
        ParseHelper.getCategories({
            (categories:[Category]?, error:NSError?) in
            if(error == nil) {
                self.categories = categories!
                self.photos.reloadData()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cell = photos.dequeueReusableCellWithIdentifier(EventPhotoTableViewCell.flatReuseIdentifier, forIndexPath: indexPath) as? EventPhotoTableViewCell else {
            return UITableViewCell()
        }

        let category:Category! = categories[indexPath.row]
        
        cell.name?.text = category.name

        if let photoURLString = category.photo.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo?.sd_setImageWithURL(photoURL)
        }

        if let fetchingDataIndexPath = self.fetchingDataIndexPath where fetchingDataIndexPath == indexPath {
            cell.showActivityIndicator()
        } else {
            cell.hideActivityIndicator()
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(EventPhotoTableViewCell.flatReuseIdentifier, forIndexPath: indexPath) as? EventPhotoTableViewCell else {
            return
        }

        fetchDataForIndexPath(indexPath)

        let category = categories[indexPath.row]

        if let photoURLString = category.photo.url,
            photoURL = NSURL(string: photoURLString) {
            cell.photo?.sd_setImageWithURL(photoURL)
        }
    }

    func fetchDataForIndexPath(indexPath: NSIndexPath) {
        guard let  vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("PhotosTableViewController") as? PhotosTableViewController else {
            return
        }

        fetchingDataIndexPath = indexPath
        photos.reloadData()

        let category = categories[indexPath.row]

        ParseHelper.getEventPhotos(category) { [weak self] photos, error in
            self?.fetchingDataIndexPath = nil
            self?.photos.reloadData()

            guard let photos = photos
                where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
            }

            if photos.isEmpty {
                self?.delegate.madeEventPictureChoice(category.photo, pickedPhoto: nil)
                self?.navigationController?.popViewControllerAnimated(true)

                return
            }

            vc.delegate = self
            vc.category = category
            vc.eventPhotos = photos

            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/2
    }

    func madeCategoryPhotoChoice(eventPhoto: EventPhoto) {
        delegate.madeEventPictureChoice(eventPhoto.photo, pickedPhoto: nil)
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
        delegate.madeEventPictureChoice(imageFile, pickedPhoto: pickedImage)
        dismissViewControllerAnimated(true, completion: {
            self.navigationController?.popViewControllerAnimated(true)
        }) //5
        
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

