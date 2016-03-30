//
//  EditProfileViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate {
    
    
    let picker = UIImagePickerController()
    var editdone:UIBarButtonItem!
    var gender:Int!
    var avatarData:NSData?
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    

    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var about: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = PFUser.currentUser() else {
            return
        }

        picker.delegate = self
        
        name.text = currentUser.objectForKey("name") as? String
      
        gender = currentUser.objectForKey("gender") as! Int
        
        if gender == 0 {
            femaleAction(true)
        } else {
            maleAction(true)
        }
        
        if let avatarFile = PFUser.currentUser()?.objectForKey("avatar") as? PFFile,
            photoURLString = avatarFile.url,
            photoURL = NSURL(string: photoURLString) {
            avatar.layer.borderColor = UIColor.whiteColor().CGColor
            avatar.sd_setImageWithURL(photoURL)
        }

        about.text = currentUser.objectForKey("about") as? String
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
    
    @IBAction func editdone(sender: AnyObject) {
        PFUser.currentUser()?.setObject(gender, forKey: "gender")
        
        if avatarData != nil {
            let imageFile:PFFile = PFFile(data: avatarData!)!
            PFUser.currentUser()!.setObject(imageFile, forKey: "avatar")
        }
        PFUser.currentUser()?.setObject(name.text!, forKey: "name")
        
        PFUser.currentUser()?.setObject(about.text!, forKey: "about")
        PFUser.currentUser()!.saveInBackgroundWithBlock({
            result, error in
            if error != nil {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    @IBAction func maleAction(sender: AnyObject) {
        maleButton.backgroundColor = Color.GenderActiveColor
        femaleButton.backgroundColor = UIColor.whiteColor()
        gender = 1
    }
    @IBAction func femaleAction(sender: AnyObject) {
        maleButton.backgroundColor = UIColor.whiteColor()
        femaleButton.backgroundColor = Color.GenderActiveColor
        gender = 0
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = (info[UIImagePickerControllerEditedImage] as! UIImage).resizeToDefault()
        avatarData = UIImageJPEGRepresentation(pickedImage, 70)
        avatar.image = pickedImage
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
