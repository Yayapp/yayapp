//
//  CreateGroupViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//


import UIKit
import MapKit
import SVProgressHUD
import LocationPicker

protocol GroupCreationDelegate : NSObjectProtocol {
    func groupCreated(group:Category)
}

final class CreateGroupViewController: KeyboardAnimationHelper, ChooseLocationDelegate, ChooseEventPictureDelegate, WriteAboutDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet private weak var eventImage: UIImageView?
    @IBOutlet private weak var eventPhoto: UIButton?
    @IBOutlet private weak var location: UIButton?
    @IBOutlet private weak var spinner: UIActivityIndicatorView?
    @IBOutlet private weak var name: UITextField?
    @IBOutlet private weak var descr: UIButton?
    @IBOutlet private weak var publicButton: UIButton?
    @IBOutlet private weak var privateButton: UIButton?
    @IBOutlet private weak var createButton: UIButton?

    private var isPrivate: Bool = false
    private var longitude: Double?
    private var latitude: Double?
    private var chosenPhoto: File?
    private var descriptionText: String! = ""
    private var deleteGroupButton: UIBarButtonItem!

    var group: Category?
    var isEditMode = false

    weak var delegate:GroupCreationDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        name?.delegate = self
        if group != nil {
            update()
            title = NSLocalizedString("Edit Group", comment: "")
        } else {
            title = NSLocalizedString("Create Group", comment: "")
        }
        self.publicAction(true)

        let submitButtonTitle = isEditMode ? NSLocalizedString("Save", comment: "") : NSLocalizedString("Create Group & Invite Friends", comment: "")
        createButton?.setTitle(submitButtonTitle, forState: .Normal)

        if isEditMode && group?.owner?.objectId == ParseHelper.sharedInstance.currentUser?.objectId {
            deleteGroupButton = UIBarButtonItem(title: NSLocalizedString("Delete", comment: ""),
                                                style: .Plain,
                                                target: self,
                                                action: #selector(CreateGroupViewController.deleteGroup))
            deleteGroupButton.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.redColor()], forState: .Normal)
            navigationItem.setRightBarButtonItem(deleteGroupButton, animated: false)
        }
    }

    func update() {
        ParseHelper.fetchObject(group!, completion: {
            result, error in
            if error == nil {
                self.title  = self.group!.name
                self.name?.text = self.group!.name
                self.descriptionText = self.group!.summary
                self.descr?.setTitle(self.group!.summary, forState: .Normal)
                self.madeEventPictureChoice(self.group!.photo, pickedPhoto: nil)
                if (self.group!.isPrivate) {
                    self.privateAction(true)
                self.madeLocationChoice(CLLocationCoordinate2D(latitude: self.group!.location!.latitude, longitude: self.group!.location!.longitude))
                } else {
                    self.publicAction(true)
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
    }
 
    @IBAction func publicAction(sender: AnyObject) {
        privateButton?.backgroundColor = UIColor.whiteColor()
        publicButton?.backgroundColor = Color.PrimaryActiveColor
        isPrivate = false
    }
    
    @IBAction func privateAction(sender: AnyObject) {
        privateButton?.backgroundColor = Color.PrimaryActiveColor
        publicButton?.backgroundColor = UIColor.whiteColor()
        isPrivate = true
    }

    @IBAction func addLocationButtonPressed(sender: AnyObject) {
        let locationPicker = LocationPickerViewController()
        locationPicker.currentLocationButtonBackground = .whiteColor()
        locationPicker.mapType = .Standard
        locationPicker.searchBarPlaceholder = "Search by address"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        locationPicker.completion = { location in
            guard let location = location else {
                return
            }
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            location.location.getLocationString(nil, button: self.location, timezoneCompletion: nil)
        }
        self.navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func openPhotoPicker(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ChooseEventPictureViewController") as? ChooseEventPictureViewController else {
            return
        }

        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }

    func madeLocationChoice(coordinates: CLLocationCoordinate2D){
        latitude = coordinates.latitude
        longitude = coordinates.longitude
        CLLocation(latitude: latitude!, longitude: longitude!).getLocationString(nil, button: location, timezoneCompletion: nil)
    }
    
    func madeEventPictureChoice(photo: File, pickedPhoto: UIImage?) {
        chosenPhoto = photo

        eventImage?.contentMode = .ScaleAspectFill

        if pickedPhoto != nil {
            eventImage?.image = pickedPhoto!
        } else if let photoURLString = photo.url,
            photoURL = NSURL(string: photoURLString) {
            eventImage?.sd_setImageWithURL(photoURL, completed: { (_, error, _, _) in
                if error != nil {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func openAboutMeEditor(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("WriteAboutViewController") as? WriteAboutViewController else {
            return
        }
        
        vc.delegate = self
        vc.textAbout = descriptionText
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func writeAboutDone(text: String) {
        self.descriptionText = text
        self.descr?.setTitle(text.isEmpty ? NSLocalizedString("Add Description", comment: "") : text, forState: .Normal)
    }
    
    @IBAction func create(sender: AnyObject) {
        guard let name = name?.text else {
            MessageToUser.showDefaultErrorMessage("Please enter name")
            return
        }
        
        if name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter name")
        } else if isPrivate && (longitude == nil || latitude == nil) {
            MessageToUser.showDefaultErrorMessage("Please choose location")
        } else if descriptionText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter description")
        } else if chosenPhoto == nil {
            MessageToUser.showDefaultErrorMessage("Please choose photo")
        } else {
            spinner?.startAnimating()
            createButton?.enabled = false
            
            if !isEditMode {
                let eventACL = ObjectACL()
                eventACL.publicWriteAccess = true
                eventACL.publicReadAccess = true
                
                self.group = Category()
                self.group!.ACL = eventACL
                self.group!.attendeeIDs = [ParseHelper.sharedInstance.currentUser!.objectId!]
            }
            
            guard let group = group,
                currentUser = ParseHelper.sharedInstance.currentUser else {
                    return
            }
            
            group.name = name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            group.summary = descriptionText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            group.owner = currentUser
            group.photo = chosenPhoto!
            group.isPrivate = isPrivate

            if let resizedImage = eventImage?.image?.resizedToSize(CGSize(width: 70, height: 70)),
                thumbImageData = UIImageJPEGRepresentation(resizedImage, 0.85) {
                group.photoThumb = File(data: thumbImageData)
            }

            if let latitude = latitude, longitude = longitude {
                group.location = GeoPoint(latitude: latitude, longitude: longitude)
            }

            ParseHelper.saveObject(group, completion: {
                (result, error) in
                if error == nil {
                    self.delegate.groupCreated(group)
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    self.spinner?.stopAnimating()
                    self.createButton?.enabled = false
                }
            })
        }
    }

    func deleteGroup() {
        let deleteGroupAlert = UIAlertController(title: nil, message: "Are you sure you want to delete your group?".localized, preferredStyle: .Alert)
        deleteGroupAlert.addAction(UIAlertAction(title: "Delete".localized, style: .Destructive, handler: { [unowned self] _ in
            SVProgressHUD.show()

            ParseHelper.deleteObject(self.group, completion: { [weak self] _, error in
                SVProgressHUD.dismiss()
                guard error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
                }

                self?.performSegueWithIdentifier("chooseCategorySegue", sender: self)
                })
        }))
        deleteGroupAlert.addAction(UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil))
        presentViewController(deleteGroupAlert, animated: true, completion: nil)
    }
}
