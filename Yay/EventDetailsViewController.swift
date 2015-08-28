//
//  EventDetailsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
    
    var event:Event!
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation!
    var attendeeButtons:[UIButton]!
    var attendees:[PFUser] = []
    var conversation:LYRConversation!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var descr: UITextView!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    
    @IBOutlet weak var author: UIButton!
    
    @IBOutlet weak var attend: UIButton!
    @IBOutlet weak var attended1: UIButton!
    
    @IBOutlet weak var attended2: UIButton!
    
    @IBOutlet weak var attended3: UIButton!
    
    @IBOutlet weak var attended4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attendeeButtons = [attended1,attended2,attended3,attended4]
        attendees = event.attendees.filter({$0.objectId != self.event.owner.objectId})
        
        title = event.name
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
      
        
        if let user = PFUser.currentUser() {
            
            
            let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
            currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
            let attendedThisEvent = !(event.attendees.filter({$0.objectId == user.objectId}).count == 0)
            if !attendedThisEvent && event.limit>event.attendees.count {
                ParseHelper.getUserRequests(event, user: user, block: {
                    result, error in
                    if (error != nil || result == nil || result!.isEmpty) {
                        self.attend.hidden = false
                    }
                })
            }
            if !attendedThisEvent {
                chatButton.enabled = false
                inviteButton.enabled = false
            }
            if event.conversation != nil {
                let query:LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
                query.predicate = LYRPredicate(property: "identifier", predicateOperator:LYRPredicateOperator.IsEqualTo, value:NSURL(string:event.conversation!))
                var error:NSError?
                conversation = appDelegate.layerClient.executeQuery(query, error:&error).firstObject as? LYRConversation
                //            conversation.delete(LYRDeletionMode.AllParticipants, error: &error)
            }
        } else {
            currentLocation = CLLocation(latitude: TempUser.location!.latitude, longitude: TempUser.location!.longitude)
            attend.hidden = false
        }
        
        var distanceBetween: CLLocationDistance = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude).distanceFromLocation(currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        title  = event.name
        name.text = event.name
        descr.text = event.summary
        
        event.photo.getDataInBackgroundWithBlock({
            (data:NSData?, error:NSError?) in
            if(error == nil) {
                var image = self.toCobalt(UIImage(data:data!)!)
                self.photo.image = image
            }
        })
        
        date.text = dateFormatter.stringFromDate(event.startDate)
        
        event.owner.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if let avatar = self.event.owner["avatar"] as? PFFile {
                avatar.getDataInBackgroundWithBlock({
                    (data:NSData?, error:NSError?) in
                    if(error == nil) {
                        var image = UIImage(data:data!)
                        self.author.setImage(image, forState: .Normal)
                        self.author.layer.borderColor = UIColor(red:CGFloat(250/255.0), green:CGFloat(214/255.0), blue:CGFloat(117/255.0), alpha: 1).CGColor
                    }
                })
            }
        })
        
        for (index, attendee) in enumerate(attendees) {
            let attendeeButton = attendeeButtons[index]
            
            attendeeButton.addTarget(self, action: "attendeeProfile:", forControlEvents: .TouchUpInside)
            attendeeButton.tag = index
            
            attendee.fetchIfNeededInBackgroundWithBlock({
                result, error in
                if let attendeeAvatar = attendee["avatar"] as? PFFile {
                    attendeeAvatar.getDataInBackgroundWithBlock({
                        (data:NSData?, error:NSError?) in
                        if(error == nil) {
                            var image = UIImage(data:data!)
                            attendeeButton.setImage(image, forState: .Normal)
                        }
                    })
                }
            })
        }
        
        distance.text = "\(distanceStr)km"
        getLocationString(event.location.latitude, longitude: event.location.longitude)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func attend(sender: AnyObject) {

        if PFUser.currentUser() == nil {
            let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_LOGIN
            blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            blurryAlertViewController.aboutText = "Please login before attending  events."
            presentViewController(blurryAlertViewController, animated: true, completion: nil)
        } else {
            spinner.startAnimating()
            event.fetchIfNeededInBackgroundWithBlock({
                (result, error) in
                
                let requestACL:PFACL = PFACL()
                requestACL.setPublicWriteAccess(true)
                requestACL.setPublicReadAccess(true)
                let request = Request()
                request.event = self.event
                request.attendee = PFUser.currentUser()!
                request.ACL = requestACL
                request.saveInBackground()
                
                self.spinner.stopAnimating()
                self.attend.hidden = true
                
                let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                blurryAlertViewController.aboutText = "Your request has been sent."
                blurryAlertViewController.messageText = "We will notify you of the outcome."
                self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
                
                
            })
        }
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
            
            if let building = placeMark.subThoroughfare {
                cityCountry.appendString(building)
            }
            
            if let address = placeMark.thoroughfare {
                if cityCountry.length>0 {
                    cityCountry.appendString(" ")
                }
                cityCountry.appendString(address)
            }
            
            if let zip = placeMark.postalCode {
                if cityCountry.length>0 {
                    cityCountry.appendString(", ")
                }
                cityCountry.appendString(zip)
            }
            if cityCountry.length>0 {
                self.location.text = cityCountry as String
            }
        })
        
    }
    
    @IBAction func chat(sender: AnyObject) {
        if (attendees.count>0) {
            if conversation == nil {
                var errors:NSError?
                let participants = NSMutableSet()
                
                participants.addObject(event.owner.objectId!)
                
                for (index, attendee) in enumerate(attendees) {
                    let attendeeButton = attendeeButtons[index]
                    participants.addObject(attendee.objectId!)
                }
                
                //                    if self.conversation != nil {
                //                        var errors:NSError?
                //                        let participants = NSMutableSet()
                //                        participants.addObject(PFUser.currentUser()!.objectId!)
                //                        self.conversation.addParticipants(participants as Set<NSObject>, error: &errors)
                //                    }
                
                conversation = appDelegate.layerClient.newConversationWithParticipants(participants as Set<NSObject>, options: [LYRConversationOptionsDistinctByParticipantsKey : false ], error: &errors)
                if  self.conversation == nil {
                    println("New Conversation creation failed: \(errors)")
                }
                conversation.setValue(event.name, forMetadataAtKeyPath: "name")
                event.conversation = conversation.identifier.absoluteString!
                event.saveInBackground()
            }
            
            let controller = ConversationViewController(layerClient: appDelegate.layerClient)
            controller.conversation = conversation
            controller.displaysAddressBar = false
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    
    @IBAction func invite(sender: AnyObject) {
        
    }
    
    @IBAction func authorProfile(sender: AnyObject) {
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = event.owner
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func attendeeProfile(sender: AnyObject) {
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = attendees[sender.tag]
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func toCobalt(image:UIImage) -> UIImage{
        let inputImage:CIImage = CIImage(CGImage: image.CGImage)
        
        // Make the filter
        let colorMatrixFilter:CIFilter = CIFilter(name: "CIColorMatrix")
        colorMatrixFilter.setDefaults()
        colorMatrixFilter.setValue(inputImage, forKey:kCIInputImageKey)
        colorMatrixFilter.setValue(CIVector(x:1, y:1, z:1, w:0), forKey:"inputRVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:1, z:0, w:0), forKey:"inputGVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:0, z:1, w:0), forKey:"inputBVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:0, z:0, w:1), forKey:"inputAVector")
        
        // Get the output image recipe
        let outputImage:CIImage = colorMatrixFilter.outputImage
        
        // Create the context and instruct CoreImage to draw the output image recipe into a CGImage
        let context:CIContext = CIContext(options:nil)
        let cgimg:CGImageRef = context.createCGImage(outputImage, fromRect:outputImage.extent()) // 10
        
        return UIImage(CGImage:cgimg)!
    }
}
