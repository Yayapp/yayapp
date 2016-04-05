//
//  CreateGroupViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 26.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//


import UIKit
import MapKit

protocol GroupCreationDelegate : NSObjectProtocol {
    func groupCreated(group:Category)
}

class CreateGroupViewController: KeyboardAnimationHelper, ChooseLocationDelegate, ChooseEventPictureDelegate, WriteAboutDelegate, UIPopoverPresentationControllerDelegate {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var group:Category?
    
    var isPrivate:Bool = false
    var longitude: Double?
    var latitude: Double?
    var chosenPhoto: File?
    var delegate:GroupCreationDelegate!
    var descriptionText:String!=""
    
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventPhoto: UIButton!
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var descr: UIButton!
    
    @IBOutlet weak var publicButton: UIButton!
    
    @IBOutlet weak var privateButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.delegate = self
        
        if group != nil {
            update()
            title = "Edit Event"
        } else {
            title = "Create Event"
        }
        self.publicAction(true)
    }
    
    
    func update() {
        group!.fetchInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.title  = self.group!.name
                self.name.text = self.group!.name
                self.descriptionText = self.group!.summary
                self.descr.setTitle(self.group!.summary, forState: .Normal)
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
        privateButton.backgroundColor = UIColor.whiteColor()
        publicButton.backgroundColor = Color.PrimaryActiveColor
        isPrivate = false
        location.hidden = true
    }
    
    @IBAction func privateAction(sender: AnyObject) {
        privateButton.backgroundColor = Color.PrimaryActiveColor
        publicButton.backgroundColor = UIColor.whiteColor()
        isPrivate = true
        location.hidden = false
    }

    @IBAction func addLocationButtonPressed(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier(ChooseLocationViewController.storyboardID) as? ChooseLocationViewController else {
            return
        }

        vc.delegate = self

        presentViewController(vc, animated: true, completion: nil)
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
    
    func madeEventPictureChoice(photo: PFFile, pickedPhoto: UIImage?) {
        chosenPhoto = photo
        if pickedPhoto != nil {
            eventImage.image = pickedPhoto!
            eventImage.contentMode = UIViewContentMode.ScaleAspectFill
        } else {
            
            photo.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil) {
                    let image = UIImage(data:data!)
                    self.eventImage.image = image
                    self.eventImage.contentMode = UIViewContentMode.ScaleAspectFill
                } else {
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
        self.descr.setTitle(text, forState: .Normal)
    }
    
    
    
    @IBAction func create(sender: AnyObject) {
        
        if name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter name")
        } else if isPrivate && (longitude == nil || latitude == nil) {
            MessageToUser.showDefaultErrorMessage("Please choose location")
        } else if descriptionText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter description")
        } else if chosenPhoto == nil {
            MessageToUser.showDefaultErrorMessage("Please choose photo")
        } else {
            spinner.startAnimating()
            createButton.enabled = false
            
            if group == nil {
                let eventACL:PFACL = PFACL()
                eventACL.publicWriteAccess = true
                eventACL.publicReadAccess = true
                
                self.group = Category()
                self.group!.ACL = eventACL
                self.group!.attendees = []
            }
            self.group!.name = name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.group!.summary = descriptionText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.group!.photo = chosenPhoto!
            self.group!.owner = PFUser.currentUser()!
            if isPrivate {
                self.group!.location = PFGeoPoint(latitude: latitude!, longitude: longitude!)
            }
            self.group!.saveInBackgroundWithBlock({
                (result, error) in
                if error == nil {
                    self.group!.addObject(PFUser.currentUser()!, forKey: "attendees")
                    self.group!.saveInBackgroundWithBlock({
                        (result, error) in
                        self.delegate.groupCreated(self.group!)
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                } else {
                    self.spinner.stopAnimating()
                    self.createButton.enabled = false
                }
            })
        }
    }
}
