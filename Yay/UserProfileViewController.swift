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
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var uploadPhoto: UIButton!
    @IBOutlet weak var avatar: PFImageView!
    @IBOutlet weak var eventsCount: UILabel!
    @IBOutlet weak var interests: UILabel!
    @IBOutlet weak var about: UILabel!
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var invites: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        name.text = user.objectForKey("name") as? String
        
        if(PFUser.currentUser()?.objectId == user.objectId) {
            editdone = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editdone:"))
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
        }
        
        let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
        getLocationString(currentPFLocation.latitude, longitude: currentPFLocation.longitude)
        
        ParseHelper.getUpcomingPastEvents(user, upcoming: nil, block: {
            result, error in
            if error == nil {
                let rank = Rank.getRank(result!.count)
                self.eventsCount.text = rank.getString(self.user["gender"] as! Int)
                self.rankIcon.image = rank.getImage(self.user["gender"] as! Int)
            }
        })
        
        var query = PFUser.query()
        query!.whereKey("objectId", equalTo: user.objectId!)
        query!.includeKey("interests")
        query!.findObjectsInBackgroundWithBlock({
            (users:[AnyObject]?, error:NSError?) in
            
            if error == nil {
                let user = users as! [PFUser]
                let categories:[PFObject] = user.first!.objectForKey("interests") as! [PFObject]
                var interests:[String] = []
                for category in categories {
                    interests.append(category["name"] as! String)
                }
                let interestsStr:String = ", ".join(interests)
                //
                self.interests.text = "\(self.interests.text!) \(interestsStr)"
            }
        })
        
        
        let avatarfile = user.objectForKey("avatar") as? PFFile
        if(avatarfile != nil) {
            avatar.file = avatarfile
            avatar.loadInBackground()
        }
        if user["about"] != nil {
            setAboutMe((user["about"]! as! String))
        }
        let userInvites = user["invites"] as! Int
        invites.text = "\(invites.text!) \(userInvites)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAboutMe(text:String){
        let font17 = UIFont.systemFontOfSize(17)
        let font12 = UIFont.systemFontOfSize(12)
        let myMutableString = NSMutableAttributedString(string: "About Me: "+text, attributes: [NSFontAttributeName:font17])
        myMutableString.addAttribute(NSFontAttributeName, value: font12, range: NSRange(location: count(about.text!), length: count(text)))
        
        about.attributedText = myMutableString
    }

    func getLocationString(latitude: Double, longitude: Double){
        let geoCoder = CLGeocoder()
        let cllocation = CLLocation(latitude: latitude, longitude: longitude)
        var cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(cllocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as? [CLPlacemark]
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // City
            if let city = placeMark.addressDictionary["City"] as? String {
                cityCountry.appendString(city)
            }
            // Country
            if let country = placeMark.addressDictionary["Country"] as? String {
                if cityCountry.length>0 {
                    cityCountry.appendString(", ")
                }
                cityCountry.appendString(country)
            }
            if cityCountry.length>0 {
                self.location.text = cityCountry as String
            }
        })
        
    }
    
    func madeCategoryChoice(category: Category) {
        user.fetchIfNeededInBackgroundWithBlock({
            (result, error) in
            if (error == nil) {
                
                let categories = self.user.objectForKey("interests") as! [Category]
                var interests:[String] = []
                for category in categories {
                    interests.append(category.name)
                }
                let interestsStr:String = ", ".join(interests)
                //
                self.interests.text = "\(self.interests.text!) \(interestsStr)"
            }
        })
        
        
        PFUser.currentUser()!.fetchIfNeededInBackgroundWithBlock({
            (result, error) in
            PFUser.currentUser()!.addObject(category, forKey: "interests")
            PFUser.currentUser()!.saveInBackgroundWithBlock({
                (result, error) in
                let categories = PFUser.currentUser()!.objectForKey("interests") as! [Category]
                var interests:[String] = []
                for category in categories {
                    interests.append(category.name)
                }
                let interestsStr:String = ", ".join(interests)
                //
                self.interests.text = "\(self.interests.text!) \(interestsStr)"
            })
        })
    }
    
    func writeAboutDone(text: String) {
        user["about"] = text
        user.saveInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.setAboutMe(text)
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
    
    func openCategoryPicker() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseCategoryViewController") as! ChooseCategoryViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func openAboutMeEditor() {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("WriteAboutViewController") as! WriteAboutViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        
        var detailPopover: UIPopoverPresentationController = vc.popoverPresentationController!
        detailPopover.delegate = self
        detailPopover.sourceView = uploadPhoto
        
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Down
        presentViewController(vc,
            animated: true, completion:nil)
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        picker.cameraCaptureMode = .Photo
        picker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        picker.showsCameraControls = true;
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func editdone(sender: AnyObject) {
        if(isEditingProfile) {
            uploadPhoto.hidden = true
            editdone.title = "Edit"
            isEditingProfile = false
            interests.backgroundColor = UIColor.clearColor()
            about.backgroundColor = UIColor.clearColor()
        } else {
            uploadPhoto.hidden = false
            editdone.title = "Done"
            isEditingProfile = true
            interests.backgroundColor = UIColor(red:CGFloat(48/255.0), green:CGFloat(56/255.0), blue:CGFloat(58/255.0), alpha: 1)
            about.backgroundColor = UIColor(red:CGFloat(48/255.0), green:CGFloat(56/255.0), blue:CGFloat(58/255.0), alpha: 1)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let pickedImage:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let imageData = UIImagePNGRepresentation(pickedImage)
        let imageFile:PFFile = PFFile(data: imageData)
        avatar.image = pickedImage
        
        PFUser.currentUser()!.setObject(imageFile, forKey: "avatar")
        PFUser.currentUser()!.saveInBackgroundWithBlock({
            result, error in
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
    
}
