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
        
        
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        if let user = PFUser.currentUser() {
            let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
            currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
            let attendedThisEvent = !(event.attendees.filter({$0.objectId == user.objectId}).count == 0)
            if !attendedThisEvent && event.limit>event.attendees.count {
                attend.hidden = false
            }
            if !attendedThisEvent {
                chatButton.enabled = false
                inviteButton.enabled = false
            }
            
            let query:LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
            query.predicate = LYRPredicate(property: "identifier", predicateOperator:LYRPredicateOperator.IsEqualTo, value:NSURL(string:event.conversation))
            var error:NSError?
            conversation = appDelegate.layerClient.executeQuery(query, error:&error).firstObject as? LYRConversation
            //            conversation.delete(LYRDeletionMode.AllParticipants, error: &error)
        } else {
            currentLocation = CLLocation(latitude: TempUser.location!.latitude, longitude: TempUser.location!.longitude)
            attend.hidden = false
        }
        
        var distanceBetween: CLLocationDistance = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude).distanceFromLocation(currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        title  = event.name
        name.text = event.name
        descr.text = event.summary
        photo.file = event.photo
        photo.loadInBackground()
        date.text = dateFormatter.stringFromDate(event.startDate)
        
        event.owner.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if let avatar = self.event.owner["avatar"] as? PFFile {
                avatar.getDataInBackgroundWithBlock({
                    (data:NSData?, error:NSError?) in
                    if(error == nil) {
                        var image = UIImage(data:data!)
                        self.author.setImage(image, forState: .Normal)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
                self.event.addObject(PFUser.currentUser()!, forKey: "attendees")
                self.event.saveInBackgroundWithBlock({
                    (result, error) in
                    
                    if self.conversation != nil {
                        var errors:NSError?
                        let participants = NSMutableSet()
                        participants.addObject(PFUser.currentUser()!.objectId!)
                        self.conversation.addParticipants(participants as Set<NSObject>, error: &errors)
                    }
                    
                    let attendeeButton = self.attendeeButtons[self.attendees.count]
                    
                    attendeeButton.addTarget(self, action: "attendeeProfile:", forControlEvents: .TouchUpInside)
                    attendeeButton.tag = self.attendees.count
                    let attendeeAvatar = PFUser.currentUser()!.objectForKey("avatar") as? PFFile
                    if(attendeeAvatar != nil) {
                        attendeeAvatar!.getDataInBackgroundWithBlock({
                            (data:NSData?, error:NSError?) in
                            if(error == nil) {
                                var image = UIImage(data:data!)
                                attendeeButton.setImage(image, forState: .Normal)
                            }
                        })
                    }
                    
                    
                    self.spinner.stopAnimating()
                    self.attend.hidden = true
                    self.chatButton.enabled = true
                    
                    let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                    blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                    blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                    blurryAlertViewController.aboutText = "Your request has been sent."
                    blurryAlertViewController.messageText = "We will notify you of the outcome."
                    self.presentViewController(blurryAlertViewController, animated: true, completion: nil)

                })
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
    
}
