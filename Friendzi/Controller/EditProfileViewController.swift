//
//  EditProfileViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

final class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPopoverPresentationControllerDelegate {

    @IBOutlet private weak var maleButton: UIButton?
    @IBOutlet private weak var femaleButton: UIButton?
    @IBOutlet private weak var name: UITextField?
    @IBOutlet private weak var avatar: UIImageView?
    @IBOutlet private weak var about: UITextView?

    private let picker = UIImagePickerController()
    private var editdone: UIBarButtonItem?
    private var avatarData: NSData?
    private var gender: Int?
    private var isShowingBioPlaceholder = true

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }

        picker.delegate = self
        
        name?.text = currentUser.name
      
        gender = currentUser.gender
        
        if gender == 0 {
            femaleAction(true)
        } else {
            maleAction(true)
        }
        
         if let avatarFile = ParseHelper.sharedInstance.currentUser?.avatar,
            photoURLString = avatarFile.url,
            photoURL = NSURL(string: photoURLString) {
            avatar?.layer.borderColor = UIColor.whiteColor().CGColor
            avatar?.sd_setImageWithURL(photoURL)
        }

        if let bio = currentUser.about where bio.characters.count > 0 {
            isShowingBioPlaceholder = false
            about?.textColor = .blackColor()
            about?.text = bio
        }
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.picker.showsCameraControls = true;
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Library", style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true //2
            self.picker.sourceType = .PhotoLibrary //3
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func editdone(sender: AnyObject) {
        SVProgressHUD.show()
        ParseHelper.sharedInstance.currentUser?.gender = gender

        if avatarData != nil {
            let imageFile = File(data: avatarData!)!
            ParseHelper.sharedInstance.currentUser!.avatar = imageFile
        }

        ParseHelper.sharedInstance.currentUser?.name = name?.text

        let aboutWithoutExtraLines = about?.text.stringByReplacingOccurrencesOfString("\\n+",
                                                                                     withString: "\n",
                                                                                     options: .RegularExpressionSearch,
                                                                                     range:nil)
        ParseHelper.sharedInstance.currentUser?.about = isShowingBioPlaceholder ? "" : aboutWithoutExtraLines

        ParseHelper.saveObject(ParseHelper.sharedInstance.currentUser!, completion: {
            result, error in
            SVProgressHUD.dismiss()

            if error != nil {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
    
    @IBAction func maleAction(sender: AnyObject) {
        maleButton?.backgroundColor = Color.GenderActiveColor
        femaleButton?.backgroundColor = UIColor.whiteColor()
        gender = 1
    }
    @IBAction func femaleAction(sender: AnyObject) {
        maleButton?.backgroundColor = UIColor.whiteColor()
        femaleButton?.backgroundColor = Color.GenderActiveColor
        gender = 0
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = (info[UIImagePickerControllerEditedImage] as! UIImage).resizeToDefault()

        avatarData = UIImageJPEGRepresentation(pickedImage, 70)
        avatar?.image = pickedImage

        picker.dismissViewControllerAnimated(true, completion: nil)
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

    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }

    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        if isShowingBioPlaceholder {
            textView.text = nil
            textView.textColor = .blackColor()
        }

        textView.becomeFirstResponder()
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = NSLocalizedString("Bio", comment: "")
            textView.textColor = .lightGrayColor()

            isShowingBioPlaceholder = true
        
        } else {
            isShowingBioPlaceholder = false
        }

        textView.resignFirstResponder()
    }
}
