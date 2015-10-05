//
//  EventDetailsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MessageUI

class EventDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate, EventCreationDelegate {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var event:Event!
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation!
    var attendeeButtons:[UIButton]!
    var attendees:[PFUser] = []
    var conversation:LYRConversation!
    var delegate:EventChangeDelegate!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UIButton!
    
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
    
    @IBOutlet weak var usersView: UIView!
    var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomConstraint = NSLayoutConstraint (item: usersView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: -20)
      
        attendeeButtons = [attended1,attended2,attended3,attended4]
        
        title = event.name
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        if(PFUser.currentUser()?.objectId == event.owner.objectId) {
            let editdone = UIBarButtonItem(image:UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editEvent:"))
            editdone.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
            attend.setImage(UIImage(named: "cancelevent_button"), forState: .Normal)
            self.attend.hidden = false
        }
        
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        event.fetchInBackgroundWithBlock({
            result, error in
            
            if error == nil {
                self.attendees = self.event.attendees.filter({$0.objectId != self.event.owner.objectId})
                
                for var index = 0; index < (self.event.limit-1); ++index {
                    self.attendeeButtons[index].setImage(UIImage(named: "upload_pic"), forState: .Normal)
                }
                
                let currentPFLocation = PFUser.currentUser()!.objectForKey("location") as! PFGeoPoint
                self.currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
                
                let attendedThisEvent = !(self.event.attendees.filter({$0.objectId == PFUser.currentUser()!.objectId}).count == 0)
                
                if(PFUser.currentUser()?.objectId != self.event.owner.objectId) {
                    
                    if !attendedThisEvent && self.event.limit>self.event.attendees.count {
                        
                        self.chatButton.enabled = false
                        
                        ParseHelper.getUserRequests(self.event, user: PFUser.currentUser()!, block: {
                            result, error in
                            if (error == nil) {
                                if (result == nil || result!.isEmpty){
                                    self.attend.hidden = false
                                } else {
                                    self.attend.removeFromSuperview()
                                    self.view.addConstraint(self.bottomConstraint)
                                }
                            } else {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        if !attendedThisEvent {
                            self.chatButton.enabled = false
                        }
                        self.attend.removeFromSuperview()
                        self.view.addConstraint(self.bottomConstraint)
                    }
                }
                
                
                if self.event.conversation != nil {
                    let query:LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
                    query.predicate = LYRPredicate(property: "identifier", predicateOperator:LYRPredicateOperator.IsEqualTo, value:NSURL(string:self.event.conversation!))
                    do {
                        self.conversation = try self.appDelegate.layerClient.executeQuery(query).firstObject as? LYRConversation
                    } catch {
                        self.conversation = nil
                    }
                    //            conversation.delete(LYRDeletionMode.AllParticipants, error: &error)
                }
                
                self.event.owner.fetchIfNeededInBackgroundWithBlock({
                    result, error in
                    if error == nil {
                        if let avatar = self.event.owner["avatar"] as? PFFile {
                            if avatar.isDataAvailable {
                                do {
                                    self.author.setImage(UIImage(data: try avatar.getData()), forState: .Normal)
                                } catch {
                                    //
                                }
                                self.author.layer.borderColor = UIColor(red:CGFloat(250/255.0), green:CGFloat(214/255.0), blue:CGFloat(117/255.0), alpha: 1).CGColor
                            } else {
                            avatar.getDataInBackgroundWithBlock({
                                (data:NSData?, error:NSError?) in
                                if(error == nil) {
                                    let image = UIImage(data:data!)
                                    self.author.setImage(image, forState: .Normal)
                                    self.author.layer.borderColor = UIColor(red:CGFloat(250/255.0), green:CGFloat(214/255.0), blue:CGFloat(117/255.0), alpha: 1).CGColor
                                } else {
                                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                                }
                            })
                            }
                        }
                    } else {
                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                    }
                })
                
                for (index, attendee) in self.attendees.enumerate() {
                    let attendeeButton = self.attendeeButtons[index]
                    
                    attendeeButton.addTarget(self, action: "attendeeProfile:", forControlEvents: .TouchUpInside)
                    attendeeButton.tag = index
                    
                    attendee.fetchIfNeededInBackgroundWithBlock({
                        result, error in
                        if error == nil {
                            if let attendeeAvatar = attendee["avatar"] as? PFFile {
                                if attendeeAvatar.isDataAvailable {
                                    do {
                                        attendeeButton.setImage(UIImage(data: try attendeeAvatar.getData()), forState: .Normal)
                                    } catch {
                                        //
                                    }
                                } else {
                                attendeeAvatar.getDataInBackgroundWithBlock({
                                    (data:NSData?, error:NSError?) in
                                    if(error == nil) {
                                        let image = UIImage(data:data!)
                                        attendeeButton.setImage(image, forState: .Normal)
                                    } else {
                                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                                    }
                                })
                                }
                            }
                        } else {
                            MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                        }
                    })
                }
                self.update()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
            
        })
    }
    
    func update() {
        let distanceBetween: CLLocationDistance = CLLocation(latitude: self.event.location.latitude, longitude: self.event.location.longitude).distanceFromLocation(self.currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        self.title  = self.event.name
        self.name.text = self.event.name
        self.descr.text = self.event.summary
        self.photo.file = self.event.photo
        self.photo.loadInBackground()
        
        self.date.text = self.dateFormatter.stringFromDate(self.event.startDate)
        self.distance.text = "\(distanceStr)km"
        self.getLocationString(self.event.location.latitude, longitude: self.event.location.longitude)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func attend(sender: AnyObject) {
        if(PFUser.currentUser()?.objectId == event.owner.objectId) {
            let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_DELETE
            blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            blurryAlertViewController.messageText = "Sorry, are you sure you want to delete this event?"
            blurryAlertViewController.hasCancelAction = true
            blurryAlertViewController.event = event
            blurryAlertViewController.completion = {
                self.delegate.eventRemoved(self.event)
                self.navigationController?.popViewControllerAnimated(false)
            }
            self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
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
                self.attend.frame = CGRectZero
                
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
        let cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(cllocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as [CLPlacemark]!
            
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
                self.location.setTitle(cityCountry as String, forState: .Normal)
            }
        })
        
    }
    
    @IBAction func chat(sender: AnyObject) {
        if (attendees.count>0) {
            if conversation == nil {
                let participants = NSMutableSet()
                
                participants.addObject(event.owner.objectId!)
                
                for (_, attendee) in attendees.enumerate() {
                    participants.addObject(attendee.objectId!)
                }
                
                do {
                    conversation = try self.appDelegate.layerClient.newConversationWithParticipants(participants as Set<NSObject>, options: [LYRConversationOptionsDistinctByParticipantsKey : false ])
                } catch {
                    conversation = nil
                }
                if  self.conversation != nil {
                    conversation.setValue(event.name, forMetadataAtKeyPath: "name")
                    event.conversation = conversation.identifier.absoluteString
                    event.saveInBackground()
                }
                
            }
            let controller = ConversationViewController(layerClient: appDelegate.layerClient)
            controller.conversation = conversation
            controller.displaysAddressBar = false
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    
    @IBAction func invite(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let userName = PFUser.currentUser()?.objectForKey("name") as! String
        let emailTitle = "\(userName) shared happening from Friendzi app"
        let messageBody = "Hi, please check this happening \"\(event.name)\" on \(dateFormatter.stringFromDate(event.startDate)).\n\nhttp://friendzy.io/"
        
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setSubject(emailTitle)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
    
    func eventCreated(event:Event) {
        self.event = event
        update()
        delegate.eventChanged(event)
    }
    
    @IBAction func editEvent(sender: AnyObject){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CreateEventViewController") as! CreateEventViewController
        vc.event = event
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openMapForPlace(sender: AnyObject) {
        
        let latitute:CLLocationDegrees =  event.location.latitude
        let longitute:CLLocationDegrees =  event.location.longitude
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(event.name)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}
protocol EventChangeDelegate : NSObjectProtocol {
    func eventChanged(event:Event)
    func eventRemoved(event:Event)
}
