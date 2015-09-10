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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func uploadPhoto(sender: AnyObject) {
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        picker.showsCameraControls = true;
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile:PFFile = PFFile(data: imageData)
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
    //What to do if the image picker cancels.
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
