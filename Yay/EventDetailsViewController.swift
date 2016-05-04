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
    var attendees:[User] = []
    var delegate:EventChangeDelegate!
    
    @IBOutlet weak var eventActionButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var photo: UIImageView!
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
    @IBOutlet weak var switherPlaceholderTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var attendButtonHeight: NSLayoutConstraint!

    var attendedThisEvent: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        chatButton.enabled = false

        switherPlaceholderTopSpace.constant = view.bounds.width / 160 * 91
        
        descr.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        attendeeButtons = [attended1,attended2,attended3,attended4]
        
        title = event.name

        let shareButton = UIBarButtonItem(title: NSLocalizedString("Invite", comment: ""), style: .Plain, target: self, action: #selector(EventDetailsViewController.shareEvent))
        shareButton.tintColor = Color.PrimaryActiveColor
        navigationItem.setRightBarButtonItem(shareButton, animated: false)
        
        if ParseHelper.sharedInstance.currentUser?.objectId == event.owner!.objectId {
            eventActionButton.setImage(UIImage(named: "edit_icon"), forState: .Normal)
            eventActionButton.tintColor = Color.PrimaryActiveColor
        } else {
            if let user = ParseHelper.sharedInstance.currentUser {
                ParseHelper.countReports(event, user: user, completion: { [weak self]
                    count in
                    if count == 0 {
                        self?.eventActionButton.tintColor = .redColor()
                        self?.eventActionButton.setImage(UIImage(named: "reporticon"), forState: .Normal)
                    }
                })
            } else {
                
            }
        }

        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"

        ParseHelper.fetchEvent(event.objectId!, completion: { [weak self] fetchedEvent, error in
            guard let fetchedEvent = fetchedEvent as? Event where error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                return
            }

            self?.event = fetchedEvent
            
            if let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId {
                self?.attendButton.setTitle(self?.attendTitle(fetchedEvent.attendeeIDs.contains(currentUserID)), forState: .Normal)
                let isAttendButtonHidden = currentUserID == self?.event.owner?.objectId
                self?.attendButton.hidden = isAttendButtonHidden
                self?.attendButtonHeight.constant = isAttendButtonHidden ? 0 : 35
            }
            
            self?.attendButton.alpha = 0.0

            ParseHelper.fetchUsers(fetchedEvent.attendeeIDs.filter({$0 != fetchedEvent.owner!.objectId}), completion: { (fetchedUsers, error) in
                guard let fetchedUsers = fetchedUsers where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
                }

                self?.attendees = fetchedUsers

                for var index = 0; index < (fetchedEvent.limit-1); index += 1 {
                    self?.attendeeButtons[index].setImage(UIImage(named: "upload_pic"), forState: .Normal)
                }
                let currentLocation = ParseHelper.sharedInstance.currentUser!.location
                self?.currentLocation = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)

                ParseHelper.fetchObject(fetchedEvent.owner, completion: {
                    result, error in
                    guard let fetchedObject = result,
                        fetchedOwner = User(object: fetchedObject) where error == nil else {
                            MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                        return
                    }

                    if let avatarURLString = fetchedOwner.avatar?.url,
                        avatarURL = NSURL(string: avatarURLString) {
                        self?.author.sd_setImageWithURL(avatarURL, forState: .Normal, completed: { (_, error, _, _) in
                            guard error == nil else {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)

                                return
                            }

                            self?.author.layer.cornerRadius = (self?.author.frame.width)! / 2
                        })
                    }
                })

                let allAttendeesWithoutOwner = fetchedUsers.filter({ $0.objectId != fetchedEvent.owner!.objectId })
                let attendees = allAttendeesWithoutOwner[0..<min(allAttendeesWithoutOwner.count, self?.attendeeButtons?.count ?? 0)]

                for (index, attendee) in attendees.enumerate() {
                    let attendeeButton = self?.attendeeButtons[index]

                    attendeeButton?.addTarget(self, action: "attendeeProfile:", forControlEvents: .TouchUpInside)
                    attendeeButton?.tag = index

                    if let attendeeAvatarURLString = attendee.avatar?.url,
                        attendeeAvatarURL = NSURL(string: attendeeAvatarURLString) {
                        attendeeButton?.sd_setImageWithURL(attendeeAvatarURL, forState: .Normal, completed: { (_, _, _, _) in
                            attendeeButton?.hidden = false
                        })
                    } else {
                        attendeeButton?.setImage(UIImage(named: "upload_pic"), forState: .Normal)
                        MessageToUser.showDefaultErrorMessage("Some user has no avatar.")
                    }
                }

                self?.chatButton.enabled = true

                self?.attendedThisEvent = !(fetchedEvent.attendeeIDs.filter({$0 == ParseHelper.sharedInstance.currentUser?.objectId}).count == 0) || ParseHelper.sharedInstance.currentUser?.objectId == fetchedEvent.owner!.objectId
                
                self?.chatButton.selected = !(self?.attendedThisEvent ?? false)
                
                if(ParseHelper.sharedInstance.currentUser?.objectId != fetchedEvent.owner!.objectId) {
                    if self?.attendedThisEvent != true && fetchedEvent.limit > fetchedEvent.attendeeIDs.count {
                        ParseHelper.getUserRequests(fetchedEvent, user: ParseHelper.sharedInstance.currentUser!, block: {
                            result, error in
                            if (error == nil) {
                                if (result == nil || result!.isEmpty){
                                    if let attendeeButton = self?.attendeeButtons[fetchedUsers.count] {
                                        attendeeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                                        attendeeButton.addTarget(self, action: #selector(EventDetailsViewController.attend(_:)), forControlEvents: .TouchUpInside)
                                        attendeeButton.setImage(nil, forState: .Normal)
                                        attendeeButton.setTitle("JOIN", forState: .Normal)
                                        attendeeButton.hidden = false
                                        self?.attendButton.alpha = 1.0
                                    }
                                } else {
                                    self?.attendButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
                                    self?.attendButton.setImage(nil, forState: .Normal)
                                    self?.attendButton.setTitle("Pending…", forState: .Normal)
                                    self?.attendButton.backgroundColor = UIColor(red:0.93, green:0.40, blue:0.29, alpha:1.00)
                                    self?.attendButton.hidden = false
                                    self?.attendButton.alpha = 1.0
                                }
                            } else {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        self?.attendButton.alpha = 1.0
                    }
                } else {
                    self?.attendButton.alpha = 1.0
                }
                
                self?.update()
            })
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for button in [author, attended1, attended2, attended3, attended4] {
            button.layer.cornerRadius = button.bounds.width / 2
        }
    }

    func update() {
        let distanceBetween: CLLocationDistance = CLLocation(latitude: self.event.location.latitude, longitude: self.event.location.longitude).distanceFromLocation(self.currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        self.title  = self.event.name
        self.name.text = self.event.name
        self.descr.text = self.event.summary

        if let photoURLString = event.photo.url,
            photoURL = NSURL(string: photoURLString) {
            photo.sd_setImageWithURL(photoURL)
        }
        
        self.date.text = self.dateFormatter.stringFromDate(self.event.startDate)
        self.distance.text = distanceBetween > 0 ? "\(distanceStr)km" : nil

        CLLocation(latitude: self.event.location.latitude, longitude: self.event.location.longitude).getLocationString(nil, button: location, timezoneCompletion: nil)
    }
    
    func attendTitle(isJoined: Bool) -> String {
        return isJoined ? NSLocalizedString("Leave", comment: "") : NSLocalizedString("Join", comment: "")
    }
    
    @IBAction func attend(sender: UIButton) {
        guard let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId else {
            return
        }
        
        let isJoined = event.attendeeIDs.contains(currentUserID)

        if isJoined {
            ParseHelper.changeStateOfEvent(event, toJoined: false, completion: { result, error in
                if (error != nil) {
                    MessageToUser.showDefaultErrorMessage(NSLocalizedString("Error occurred in changing your status in current event.", comment: ""))
                }
            })

            attendButton.setTitle(NSLocalizedString("Join", comment: ""), forState: .Normal)
        } else {
            attendButton.hidden = true

            let requestACL = ObjectACL()
            requestACL.publicWriteAccess = true
            requestACL.publicReadAccess = true
            let request = Request()
            request.event = event
            request.attendee = ParseHelper.sharedInstance.currentUser!
            request.ACL = requestACL
            ParseHelper.saveObject(request, completion: nil)

            guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
                return
            }

            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
            blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            blurryAlertViewController.aboutText = "Your request has been sent."
            blurryAlertViewController.messageText = "We will notify you of the outcome."
            self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func chat(sender: AnyObject) {
        guard let _ = ParseHelper.sharedInstance.currentUser else {
            guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
                return
            }

            presentViewController(vc, animated: true, completion: nil)

            return
        }

        if (attendees.count>0) {
            guard let controller: MessagesTableViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("MessagesTableViewController") as? MessagesTableViewController else {
                return
            }

            controller.event = event
            self.navigationController!.pushViewController(controller, animated: true)
        } else {
            MessageToUser.showDefaultErrorMessage("There are no attendees yet.")
        }
    }

    @IBAction func switchToDetails(sender: AnyObject) {
        view.endEditing(true)

        chatUnderline.hidden = true
        detailsUnderline.hidden = false
        messagesContainer.hidden = true
        eventActionButton.hidden = false

        switherPlaceholderTopSpace.constant = self.view.bounds.width / 160 * 91
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func switchToChat(sender: AnyObject) {
        guard attendedThisEvent == true else {
            MessageToUser.showMessage(NSLocalizedString("Denied", comment: ""),
                                      textId: NSLocalizedString("You must be attended to this event", comment: ""))

            return
        }

        chatUnderline.hidden = false
        detailsUnderline.hidden = true
        messagesContainer.hidden = false
        eventActionButton.hidden = true

        switherPlaceholderTopSpace.constant = 0
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func invite(sender: AnyObject) {
        if ParseHelper.sharedInstance.currentUser != nil {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        } else {
            guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
                return
            }

            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let userName = ParseHelper.sharedInstance.currentUser?.name
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
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        userProfileViewController.user = event.owner
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func attendeeProfile(sender: AnyObject) {
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

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
    
    func editEvent() {
        guard let vc = UIStoryboard.createEventTab()?.instantiateViewControllerWithIdentifier("CreateEventViewController") as? CreateEventViewController,
            currentUser = ParseHelper.sharedInstance.currentUser else {
                return
        }

        vc.isEditMode = event.owner?.objectId == currentUser.objectId
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
    
    func reportButtonTapped() {
        guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
            return
        }
        
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.messageText = "You are about to flag this event for inappropriate content. Are you sure?"
        blurryAlertViewController.completion = {
            let report = Report()
            report.event = self.event
            report.user = ParseHelper.sharedInstance.currentUser!
            ParseHelper.saveObject(report, completion: {
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

    @IBAction func eventActionButtonPressed(sender: AnyObject) {
        if ParseHelper.sharedInstance.currentUser?.objectId == event.owner!.objectId {
            editEvent()
        } else {
            reportButtonTapped()
        }
    }

    func shareEvent() {
        guard let shareItemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ShareItemViewController.storyboardID) as? ShareItemViewController else {
            return
        }

        shareItemVC.modalPresentationStyle = .OverCurrentContext
        shareItemVC.modalTransitionStyle = .CrossDissolve
        shareItemVC.item = event

        presentViewController(shareItemVC, animated: true, completion: nil)
    }
}
