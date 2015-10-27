//
//  UserProfileViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 18.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChooseCategoryDelegate, WriteAboutDelegate, UIPopoverPresentationControllerDelegate {
    
   
    let picker = UIImagePickerController()
    var user:PFUser!
    var editdone:UIBarButtonItem!
    var isEditingProfile:Bool = false
    var blocked = false
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var avatar: PFImageView!
    @IBOutlet weak var eventsCount: UILabel!
    @IBOutlet weak var interests: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var blockUnblock: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = self.user.objectForKey("name") as? String
        
        name.text = user.objectForKey("name") as? String
        
        if(PFUser.currentUser()?.objectId == user.objectId) {
            editdone = UIBarButtonItem(image:UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editdone:"))
            editdone.tintColor = Color.PrimaryActiveColor
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
            
            let tblView =  UIView(frame: CGRectZero)
            tableView.tableFooterView = tblView
            tableView.tableFooterView!.hidden = true
            
        } else {
            if(PFUser.currentUser() != nil) {
            
            ParseHelper.countBlocks(PFUser.currentUser()!, user: user, completion: {
                count in
                if count > 0 {
                    self.blockUnblock.titleLabel?.text = "Unblock user"
                    self.blocked = true
                }
                self.blockUnblock.hidden = false
            })
            }
        }
        
        
        ParseHelper.getUpcomingPastEvents(user, upcoming: nil, block: {
            result, error in
            if error == nil {
                let rank = Rank.getRank(result!.count)
                self.eventsCount.text = rank.getString(self.user["gender"] as! Int)
                self.rankIcon.image = rank.getImage(self.user["gender"] as! Int)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
        let query = PFUser.query()
        query!.whereKey("objectId", equalTo: user.objectId!)
        query!.includeKey("interests")
        query!.findObjectsInBackgroundWithBlock({
            users, error in
            
            if error == nil {
                let user = users as! [PFUser]
                let categories:[PFObject] = user.first!.objectForKey("interests") as! [PFObject]
                var interests:[String] = []
                for category in categories {
                    interests.append(category["name"] as! String)
                }
                let interestsStr:String = interests.joinWithSeparator(", ")
                //
                self.setMyInterests(interestsStr)
            }
        })
        
        
        let avatarfile = user.objectForKey("avatar") as? PFFile
        if(avatarfile != nil) {
            avatar.file = avatarfile
            avatar.loadInBackground()
            avatar.layer.borderColor = UIColor.whiteColor().CGColor
        }
        if user["about"] != nil {
            setAboutMe((user["about"]! as! String))
        }
        view.bringSubviewToFront(uploadPhoto)
        
    }
    
    func setAboutMe(text:String){
        let font15 = UIFont.boldSystemFontOfSize(15)
        let font11 = UIFont.boldSystemFontOfSize(11)
        let range = NSRange(location: "About Me: ".characters.count, length: text.characters.count)
        let myMutableString = NSMutableAttributedString(string: "About Me: "+text, attributes: [NSFontAttributeName:font15])
        myMutableString.addAttribute(NSFontAttributeName, value: font11, range: range)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: Color.ProfileValuesColor , range: range)
        about.attributedText = myMutableString
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func setMyInterests(text:String){
        let font15 = UIFont.boldSystemFontOfSize(15)
        let font11 = UIFont.boldSystemFontOfSize(11)
        let range = NSRange(location: "Interests: ".characters.count, length: text.characters.count)
        let myMutableString = NSMutableAttributedString(string: "Interests: "+text, attributes: [NSFontAttributeName:font15])
        myMutableString.addAttribute(NSFontAttributeName, value: font11, range: range)
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: Color.ProfileValuesColor , range: range)
        interests.attributedText = myMutableString
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func madeCategoryChoice(categories: [Category]) {
        
        var interestsarr:[String] = []
        for category in categories {
            interestsarr.append(category.name)
        }
        let interestsStr:String = interestsarr.joinWithSeparator(", ")
        
        setMyInterests(interestsStr)
        
        PFUser.currentUser()!.setObject(categories, forKey: "interests")
        PFUser.currentUser()!.saveInBackground()
    }
    
    func writeAboutDone(text: String) {
        user["about"] = text
        user.saveInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.setAboutMe(text)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (isEditingProfile && indexPath.row == 1){
            openCategoryPicker()
        }
        if (isEditingProfile && indexPath.row == 2){
            openAboutMeEditor()
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 1 {
            interests.sizeToFit()
            if interests.frame.height<44 {
                return 44
            } else {
                return interests.frame.height + 16
            }
        } else if indexPath.row == 2 {
            about.sizeToFit()
            if about.frame.height<44 {
                return 44
            } else {
                return about.frame.height + 16
            }
        } else {
            return 44
        }
    }
    
    func openCategoryPicker() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseCategoryViewController") as! ChooseCategoryViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        vc.multi = true
        let categories = self.user.objectForKey("interests") as! [Category]
        vc.selectedCategoriesData = categories
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func openAboutMeEditor() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WriteAboutViewController") as! WriteAboutViewController
        vc.delegate = self
        if user["about"] != nil {
            vc.textAbout = user["about"]! as! String
        }
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        presentViewController(vc, animated: true, completion: nil)
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
        if(isEditingProfile) {
            uploadPhoto.hidden = true
            editdone.image = UIImage(named:"edit_icon")
            isEditingProfile = false
            interests.backgroundColor = UIColor.clearColor()
            about.backgroundColor = UIColor.clearColor()
        } else {
            uploadPhoto.hidden = false
            editdone.image = UIImage(named:"edit_done_icon")
            isEditingProfile = true
            interests.backgroundColor = Color.ProfileEditBackground
            about.backgroundColor = Color.ProfileEditBackground
        }
    }
    
    @IBAction func blockUnblock(sender: AnyObject) {
        
        if blocked == true {
            ParseHelper.removeBlocks(PFUser.currentUser()!, user: user, completion: {
                self.blockUnblock.titleLabel?.text = "Block user"
                self.blocked = false
            })
        } else {
            let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
            blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            blurryAlertViewController.hasCancelAction = true
            blurryAlertViewController.messageText = "You are about to block this user. Are you sure?"
            blurryAlertViewController.completion = {
                let block = Block()
                block.owner = PFUser.currentUser()!
                block.user = self.user
                block.saveInBackgroundWithBlock({
                    result, error in
                    if error == nil {
                        self.blockUnblock.titleLabel?.text = "Unblock user"
                        self.blocked = true
                    } else {
                        MessageToUser.showDefaultErrorMessage("Something went wrong.")
                    }
                })
            }
            self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile:PFFile = PFFile(data: imageData!)!
        avatar.image = pickedImage
        
        PFUser.currentUser()!.setObject(imageFile, forKey: "avatar")
        PFUser.currentUser()!.saveInBackgroundWithBlock({
            result, error in
            if error != nil {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
 
}
