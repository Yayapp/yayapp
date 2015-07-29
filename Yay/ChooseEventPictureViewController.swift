//
//  ChooseEventPictureViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 28.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ChooseEventPictureViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let picker = UIImagePickerController()
    var delegate:ChooseEventPictureDelegate!
    var photosList:[EventPhoto]! = []
    
    @IBOutlet weak var photos: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        photos.delegate = self
        photos.dataSource = self
        
        ParseHelper.getEventPhotos({
            (photosList:[EventPhoto]?, error:NSError?) in
            if(error == nil) {
                self.photosList = photosList!
                self.photos.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = photos.dequeueReusableCellWithIdentifier("Cell") as! EventPhotoTableViewCell
        let eventPhoto:EventPhoto! = photosList[indexPath.row]
        
        cell.name.text = eventPhoto.name
        
        cell.photo.file = eventPhoto.photo
        cell.photo.loadInBackground()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.madeEventPictureChoice(photosList[indexPath.row].photo, pickedPhoto: nil)
        self.dismissViewControllerAnimated(true, completion:nil)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = photos.dequeueReusableCellWithIdentifier("Cell") as! EventPhotoTableViewCell
        
        let height: CGFloat = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        return height
    }

    
    @IBAction func library(sender: AnyObject) {
        picker.allowsEditing = true //2
        picker.sourceType = .PhotoLibrary //3
        picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile:PFFile = PFFile(data: imageData)
        delegate.madeEventPictureChoice(imageFile, pickedPhoto: pickedImage)
        dismissViewControllerAnimated(true, completion: {
            self.dismissViewControllerAnimated(true, completion:nil)
        }) //5
        
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
protocol ChooseEventPictureDelegate : NSObjectProtocol {
    func madeEventPictureChoice(photo: PFFile, pickedPhoto: UIImage?)
}
