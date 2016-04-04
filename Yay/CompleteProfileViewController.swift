//
//  CompleteProfileViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 04.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class CompleteProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    static let storyboardID = "completeProfileViewController"

    var dismissButtonHidden = true
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var genderImage: UIImageView!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var proceed: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        nameLabel.text = PFUser.currentUser()!.objectForKey("name") as! String

        dismissButton.hidden = dismissButtonHidden
    }

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        SVProgressHUD.showWithMaskType(.Gradient)
        PFUser.logOutInBackgroundWithBlock({ error in
            SVProgressHUD.dismiss()
            guard error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                return
            }

            guard let startViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("StartViewController") as? StartViewController else {
                return
            }

            if let window = UIApplication.sharedApplication().delegate?.window {
                window!.rootViewController = startViewController
                window!.makeKeyAndVisible()
            }
        })
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
                self.check()
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
    
    func check(){
        if(PFUser.currentUser()?.objectForKey("gender") != nil && PFUser.currentUser()?.objectForKey("avatar") != nil) {
            proceed.hidden = false
        }
    }

    @IBAction func maleAction(sender: AnyObject) {
        maleButton.backgroundColor = Color.GenderActiveColor
        femaleButton.backgroundColor = UIColor.whiteColor()
        genderImage.image = UIImage(named: "newkid_rank")
        PFUser.currentUser()?.setObject(1, forKey: "gender")
        PFUser.currentUser()?.saveInBackground()
        check()
    }
    @IBAction func femaleAction(sender: AnyObject) {
        maleButton.backgroundColor = UIColor.whiteColor()
        femaleButton.backgroundColor = Color.GenderActiveColor
        genderImage.image = UIImage(named: "newfemale_kid_in_blockrank")
        PFUser.currentUser()?.setObject(0, forKey: "gender")
        PFUser.currentUser()?.saveInBackground()
        check()
    }
    
    @IBAction func proceedAction(sender: AnyObject) {
        PFUser.currentUser()?.setObject(bioField.text!, forKey: "about")
        PFUser.currentUser()?.saveInBackground()
        
    }
    
}
