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
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("PhotosTableViewController") as? PhotosTableViewController else {
            return
        }

        vc.delegate = self
        let category = categories[indexPath.row]
        vc.category = category
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/2
    }

    func madeCategoryPhotoChoice(eventPhoto: EventPhoto) {
        delegate.madeEventPictureChoice(eventPhoto.photo, pickedPhoto: nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func library(sender: AnyObject) {
        picker.allowsEditing = true //2
        picker.sourceType = .PhotoLibrary //3
        presentViewController(picker, animated: true, completion: nil)
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

