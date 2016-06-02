//
//  CompleteProfileViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 04.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

final class CompleteProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    static let storyboardID = "completeProfileViewController"

    @IBOutlet private weak var dismissButton: UIButton?
    @IBOutlet private weak var uploadPhoto: UIButton?
    @IBOutlet private weak var avatar: UIImageView?
    @IBOutlet private weak var maleButton: UIButton?
    @IBOutlet private weak var femaleButton: UIButton?
    @IBOutlet private weak var genderImage: UIImageView?
    @IBOutlet private weak var bioField: UITextView?
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var proceed: UIButton?

    private var isShowingBioPlaceholder = true
    private let picker = UIImagePickerController()

    var dismissButtonHidden = true
    var onNextButtonPressed: (() -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self

        if let currentUser = ParseHelper.sharedInstance.currentUser {
            nameLabel?.text = currentUser.name

            if let gender = currentUser.gender {
                if gender == 1 {
                    maleButton?.backgroundColor = Color.GenderActiveColor
                    femaleButton?.backgroundColor = UIColor.whiteColor()
                } else {
                    femaleButton?.backgroundColor = Color.GenderActiveColor
                    maleButton?.backgroundColor = UIColor.whiteColor()
                }
            }

            if let avatarURLString = currentUser.avatar?.url,
                avatarURL = NSURL(string: avatarURLString) {
                avatar?.sd_setImageWithURL(avatarURL)
            }

            if let bio = currentUser.about where bio.characters.count > 0 {
                isShowingBioPlaceholder = false
                bioField?.textColor = .blackColor()
                bioField?.text = bio
            }

            dismissButton?.hidden = dismissButtonHidden

            check()
        }
    }

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.Gradient)
        ParseHelper.logOutInBackgroundWithBlock({ error in
            SVProgressHUD.dismiss()
            guard error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                return
            }

            guard let startViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("StartViewController") as? StartViewController else {
                return
            }

            self.dismissViewControllerAnimated(false, completion: { 
                if let window = UIApplication.sharedApplication().delegate?.window {
                    window!.rootViewController = startViewController
                    window!.makeKeyAndVisible()
                }
            })
        })
    }

    @IBAction func uploadPhoto(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Option".localized, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo".localized, style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.picker.showsCameraControls = true;
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "From Library".localized, style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction) in
            self.picker.allowsEditing = true
            self.picker.sourceType = .PhotoLibrary
            self.picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            self.presentViewController(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        SVProgressHUD.show()

        let pickedImage: UIImage = (info[UIImagePickerControllerEditedImage] as! UIImage).resizeToDefault()
        let imageData = UIImageJPEGRepresentation(pickedImage, 70)
        let imageFile = File(data: imageData!)!
        avatar?.image = pickedImage

        typealias BoolResultBlock = (Bool?, NSError?) -> ()

        guard let currentUser = ParseHelper.sharedInstance.currentUser else {
            return
        }

        currentUser.avatar = imageFile

        ParseHelper.saveObject(currentUser) { success, error in
            SVProgressHUD.dismiss()
            guard let success = success where success == true else {
                if let error = error {
                    switch error.code {
                    case 203://Email already taken
                         MessageToUser.showDefaultErrorMessage("Hi! This email is already registered. Please close the app and login from the account you already registered".localized)
                    default:
                         MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
                return
            }

            self.check()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera".localized, message: "Sorry, this device has no camera".localized, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK".localized, style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func check(){
        if (ParseHelper.sharedInstance.currentUser?.gender != nil && ParseHelper.sharedInstance.currentUser?.avatar != nil) {
            proceed?.hidden = false
        }
    }

    @IBAction func maleAction(sender: AnyObject) {
        maleButton?.backgroundColor = Color.GenderActiveColor
        femaleButton?.backgroundColor = UIColor.whiteColor()
        genderImage?.image = UIImage(named: "newkid_rank")

        if let currentUser = ParseHelper.sharedInstance.currentUser {
            currentUser.gender = 1
            ParseHelper.saveObject(currentUser, completion: nil)
        }

        check()
    }

    @IBAction func femaleAction(sender: AnyObject) {
        maleButton?.backgroundColor = UIColor.whiteColor()
        femaleButton?.backgroundColor = Color.GenderActiveColor
        genderImage?.image = UIImage(named: "newfemale_kid_in_blockrank")

        if let currentUser = ParseHelper.sharedInstance.currentUser {
            currentUser.gender = 0
            ParseHelper.saveObject(currentUser, completion: nil)
        }

        check()
    }
    
    @IBAction func proceedAction(sender: AnyObject) {
        isShowingBioPlaceholder = "Add a bio (optional)".localized == bioField?.text || bioField?.text.characters.count == 0
        if let currentUser = ParseHelper.sharedInstance.currentUser,
            bio = bioField?.text {
            let aboutWithoutExtraLines = bio.stringByReplacingOccurrencesOfString("\\n+",
                                                                                  withString: "\n",
                                                                                  options: .RegularExpressionSearch,
                                                                                  range:nil)
            currentUser.about = isShowingBioPlaceholder ? "" : aboutWithoutExtraLines

            ParseHelper.saveObject(currentUser, completion: nil)

            if currentUser.location == nil {
                if let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EventFinderViewController") {
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            } else {
                dismissViewControllerAnimated(true, completion: { [unowned self] in
                    self.onNextButtonPressed?()
                })
            }
        }
    }

    //MARK: - UITextViewDelegate

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if isShowingBioPlaceholder {
            textView.text = nil
            textView.textColor = .blackColor()
        }
        
        return true
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = NSLocalizedString("Add a bio (optional)", comment: "")
            textView.textColor = .lightGrayColor()

            isShowingBioPlaceholder = true
        } else {
            isShowingBioPlaceholder = false
        }

        textView.resignFirstResponder()
    }
}
