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
    var delegate:EventChangeDelegate!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var descr: UITextView!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet weak var author: UIButton!
    
    @IBOutlet weak var attended1: UIButton!
    
    @IBOutlet weak var attended2: UIButton!
    
    @IBOutlet weak var attended3: UIButton!
    
    @IBOutlet weak var attended4: UIButton!
    
    @IBOutlet weak var detailsUnderline: UIView!
    
    @IBOutlet weak var chatUnderline: UIView!
    
    @IBOutlet weak var messagesContainer: UIView!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descr.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        attendeeButtons = [attended1,attended2,attended3,attended4]
        
        title = event.name
        
        if(PFUser.currentUser()?.objectId == event.owner.objectId) {
            let editdone = UIBarButtonItem(image:UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editEvent:"))
            editdone.tintColor = Color.PrimaryActiveColor
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
//            attend.setImage(UIImage(named: "cancelevent_button"), forState: .Normal)
        } else {
            if let user = PFUser.currentUser() {
                ParseHelper.countReports(event,user: user, completion: {
                    count in
                    if count == 0 {
                        let report = UIBarButtonItem(image:UIImage(named: "reporticon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("reportButtonTapped:"))
                        report.tintColor = UIColor.redColor()
                        self.navigationItem.setRightBarButtonItem(report, animated: false)
                    }
                })
            } else {
                
            }
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
                    
                
                
                self.event.owner.fetchIfNeededInBackgroundWithBlock({
                    result, error in
                    if error == nil {
                        if let avatar = self.event.owner["avatar"] as? PFFile {
                            
                                avatar.getDataInBackgroundWithBlock({
                                    (data:NSData?, error:NSError?) in
                                    if(error == nil) {
                                        let image = UIImage(data:data!)
                                        self.author.setImage(image, forState: .Normal)
                                        self.author.layer.cornerRadius = self.author.frame.width/2
                                    } else {
                                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                                    }
                                })
                            
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
                                
                                    attendeeAvatar.getDataInBackgroundWithBlock({
                                        (data:NSData?, error:NSError?) in
                                        if(error == nil) {
                                            let image = UIImage(data:data!)
                                            attendeeButton.setImage(image, forState: .Normal)
                                        } else {
                                            MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                                        }
                                    })
                            } else {
                                attendeeButton.setImage(UIImage(named: "upload_pic"), forState: .Normal)
                                MessageToUser.showDefaultErrorMessage("Some user has no avatar.")
                            }
                        } else {
                            MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                        }
                    })
                }
                
                let attendedThisEvent = !(self.event.attendees.filter({$0.objectId == PFUser.currentUser()?.objectId}).count == 0)
                
                if(PFUser.currentUser()?.objectId != self.event.owner.objectId) {
                    
                    if !attendedThisEvent && self.event.limit>self.event.attendees.count {
                        
                        self.chatButton.enabled = false
                        
                        ParseHelper.getUserRequests(self.event, user: PFUser.currentUser()!, block: {
                            result, error in
                            if (error == nil) {
                                if (result == nil || result!.isEmpty){
                                    let attendeeButton = self.attendeeButtons[self.attendees.count]
                                    attendeeButton.addTarget(self, action: "attend:", forControlEvents: .TouchUpInside)
                                    attendeeButton.setTitle("JOIN", forState: .Normal)
                                    attendeeButton.hidden = false
                                }
                            } else {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        if !attendedThisEvent {
                            self.chatButton.enabled = false
                        }
                    }
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
        CLLocation(latitude: self.event.location.latitude, longitude: self.event.location.longitude).getLocationString(nil, button: location, timezoneCompletion: nil)
    }
    
    
    @IBAction func attend(sender: UIButton) {
        if let user = PFUser.currentUser() {
            if(user.objectId == event.owner.objectId) {
                let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                blurryAlertViewController.action = BlurryAlertViewController.BUTTON_DELETE
                blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                blurryAlertViewController.messageText = "Sorry, are you sure you want to delete this event?"
                blurryAlertViewController.event = event
                blurryAlertViewController.completion = {
                    if self.delegate != nil {
                        self.delegate.eventRemoved(self.event)
                    }
                    self.navigationController?.popViewControllerAnimated(false)
                }
                self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
            } else {
                spinner.startAnimating()
                event.fetchIfNeededInBackgroundWithBlock({
                    (result, error) in
                    
                    let requestACL:PFACL = PFACL()
                    requestACL.publicWriteAccess = true
                    requestACL.publicReadAccess = true
                    let request = Request()
                    request.event = self.event
                    request.attendee = user
                    request.ACL = requestACL
                    request.saveInBackground()
                    
                    self.spinner.stopAnimating()
                    sender.hidden = true
                    
                    let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                    blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                    blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                    blurryAlertViewController.aboutText = "Your request has been sent."
                    blurryAlertViewController.messageText = "We will notify you of the outcome."
                    self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
                    
                })
            }
        } else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func chat(sender: AnyObject) {
        if PFUser.currentUser() != nil {
            if (attendees.count>0) {
                let controller: MessagesTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessagesTableViewController") as! MessagesTableViewController
                controller.event = event
                self.navigationController!.pushViewController(controller, animated: true)
            } else {
                MessageToUser.showDefaultErrorMessage("There are no attendees yet.")
            }
        } else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchToDetails(sender: AnyObject) {
        chatUnderline.hidden = true
        detailsUnderline.hidden = false
        messagesContainer.hidden = true
    }
    
    @IBAction func switchToChat(sender: AnyObject) {
        chatUnderline.hidden = false
        detailsUnderline.hidden = true
        messagesContainer.hidden = false
    }
    
    
    
    @IBAction func invite(sender: AnyObject) {
        if (PFUser.currentUser() != nil) {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        } else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let userName = PFUser.currentUser()?.objectForKey("name") as! String
        let emailTitle = "\(userName) shared happening from Friendzi app"
        let messageBody = "Hi, please check this happening \"\(event.name)\" on \(dateFormatter.stringFromDate(event.startDate)).\n\nhttp://friendzi.io/"
        
        
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
        if self.delegate != nil {
            delegate.eventChanged(event)
        }
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
    
    @IBAction func reportButtonTapped(sender: AnyObject) {
        let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.messageText = "You are about to flag this event for inappropriate content. Are you sure?"
        blurryAlertViewController.completion = {
            let report = Report()
            report.event = self.event
            report.user = PFUser.currentUser()!
            report.saveInBackgroundWithBlock({
                result, error in
                if error == nil {
                    self.navigationItem.rightBarButtonItem = nil
                    self.navigationController?.popViewControllerAnimated(true)
                } else {
                    MessageToUser.showDefaultErrorMessage("Something went wrong.")
                }
            })
        }
        self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "chat") {
            let vc = (segue.destinationViewController as! MessagesTableViewController)
            vc.event = event
        }
    }
    
}

