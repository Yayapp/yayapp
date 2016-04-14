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
    @IBOutlet weak var bioField: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var proceed: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self

        nameLabel.text = ParseHelper.sharedInstance.currentUser?.name

        dismissButton.hidden = dismissButtonHidden
    }

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        SVProgressHUD.showWithMaskType(.Gradient)
        ParseHelper.logOutInBackgroundWithBlock({ error in
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
        let imageFile = File(data: imageData!)!
        avatar.image = pickedImage

        typealias BoolResultBlock = (Bool?, NSError?) -> ()

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }

        currentUser.avatar = imageFile

        ParseHelper.saveObject(currentUser) { (result, error) in
            if error == nil {
                self.check()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        }
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
        if (ParseHelper.sharedInstance.currentUser?.gender != nil && ParseHelper.sharedInstance.currentUser?.avatar != nil) {
            proceed.hidden = false
        }
    }

    @IBAction func maleAction(sender: AnyObject) {
        maleButton.backgroundColor = Color.GenderActiveColor
        femaleButton.backgroundColor = UIColor.whiteColor()
        genderImage.image = UIImage(named: "newkid_rank")

        if let currentUser = ParseHelper.sharedInstance.currentUser {
            currentUser.gender = 1
            ParseHelper.saveObject(currentUser, completion: nil)
        }

        check()
    }

    @IBAction func femaleAction(sender: AnyObject) {
        maleButton.backgroundColor = UIColor.whiteColor()
        femaleButton.backgroundColor = Color.GenderActiveColor
        genderImage.image = UIImage(named: "newfemale_kid_in_blockrank")

        if let currentUser = ParseHelper.sharedInstance.currentUser {
            currentUser.gender = 0
            ParseHelper.saveObject(currentUser, completion: nil)
        }

        check()
    }
    
    @IBAction func proceedAction(sender: AnyObject) {
        if let currentUser = ParseHelper.sharedInstance.currentUser,
            bio = bioField.text {
            let aboutWithoutExtraLines = bio.stringByReplacingOccurrencesOfString("\\n+",
                                                                                  withString: "\n",
                                                                                  options: .RegularExpressionSearch,
                                                                                  range:nil)
            ParseHelper.sharedInstance.currentUser?.about = aboutWithoutExtraLines

            currentUser.about = bio
            ParseHelper.saveObject(currentUser, completion: nil)
        }
    }

    //MARK: - UITextViewDelegate

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == NSLocalizedString("Add a bio (optional)", comment: "") {
            textView.text = nil
            textView.textColor = .blackColor()
        }

        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = NSLocalizedString("Add a bio (optional)", comment: "")
            textView.textColor = .lightGrayColor()
        }

        textView.resignFirstResponder()
    }
}
