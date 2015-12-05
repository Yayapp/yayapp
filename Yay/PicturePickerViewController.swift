//
//  PicturePickerViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 04.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class PicturePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var avatar: PFImageView!
    
    @IBOutlet weak var proceed: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
    }


    @IBAction func uploadPhoto(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.picker.showsCameraControls = true;
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Library", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true //2
            self.picker.sourceType = .PhotoLibrary //3
            self.picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = (info[UIImagePickerControllerEditedImage] as! UIImage).resizeToDefault()
        let imageData = UIImageJPEGRepresentation(pickedImage, 70)
        let imageFile:PFFile = PFFile(data: imageData!)!
        avatar.image = pickedImage
        
        PFUser.currentUser()!.setObject(imageFile, forKey: "avatar")
        PFUser.currentUser()!.saveInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.proceed.hidden = false
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }

}
