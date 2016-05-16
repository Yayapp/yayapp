//
//  EventDetailsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MessageUI

final class EventDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate, EventChangeDelegate {

    @IBOutlet private weak var eventActionButton: UIButton!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var photo: UIImageView!
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var location: UIButton!
    @IBOutlet private weak var descr: UITextView!
    @IBOutlet private weak var date: UILabel!
    @IBOutlet private weak var distance: UILabel!
    @IBOutlet private weak var chatButton: UIButton!
    @IBOutlet private weak var detailsButton: UIButton!
    @IBOutlet private weak var author: UIButton!
    @IBOutlet private weak var attended1: UIButton!
    @IBOutlet private weak var attended2: UIButton!
    @IBOutlet private weak var attended3: UIButton!
    @IBOutlet private weak var attended4: UIButton!
    @IBOutlet private weak var detailsUnderline: UIView!
    @IBOutlet private weak var chatUnderline: UIView!
    @IBOutlet private weak var messagesContainer: UIView!
    @IBOutlet private weak var switherPlaceholderTopSpace: NSLayoutConstraint!
    @IBOutlet private weak var attendButton: UIButton!
    @IBOutlet private weak var attendButtonHeight: NSLayoutConstraint!

    private let dateFormatter = NSDateFormatter()
    private var currentLocation:CLLocation!
    private var attendeeButtons:[UIButton]!
    private var attendees:[User] = []

    var event:Event!

    weak var delegate:EventChangeDelegate!

    private var attendState: AttendState = .Hidden {
        didSet {
            attendButton.hidden = attendState == .Hidden
            attendButtonHeight.constant = attendState == .Hidden ? 0 : 35

            switch (attendState) {
            case .Pending:
                attendButton.setTitle(NSLocalizedString("Pending...", comment: ""), forState: .Normal)
                attendButton.backgroundColor = .appOrangeColor()

            case .Join:
                attendButton.setTitle(NSLocalizedString("Join Event", comment: ""), forState: .Normal)
                attendButton.backgroundColor = .appBlackColor()

            case .Leave:
                attendButton.setTitle(NSLocalizedString("Leave", comment: ""), forState: .Normal)
                attendButton.backgroundColor = .appBlackColor()

            default:
                break
            }
        }
    }

    var attendedThisEvent: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(updateAttendUI),
                                                         name: Constants.groupPendingStatusChangedNotification,
                                                         object: nil)

        attendState = .Hidden

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
            
            if ParseHelper.sharedInstance.currentUser == fetchedEvent.owner {
                self?.attendState = .Hidden
            }

            ParseHelper.fetchUsers(fetchedEvent.attendeeIDs.filter({$0 != fetchedEvent.owner!.objectId}), completion: { (fetchedUsers, error) in
                guard let fetchedUsers = fetchedUsers where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
                }

                self?.attendees = fetchedUsers

                for index in 0 ..< (fetchedEvent.limit-1) {
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

                    attendeeButton?.addTarget(self, action: #selector(EventDetailsViewController.attendeeProfile(_:)), forControlEvents: .TouchUpInside)
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

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
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

        updateAttendUI()
    }
    
    func attendTitle(isJoined: Bool) -> String {
        return isJoined ? NSLocalizedString("Leave", comment: "") : NSLocalizedString("Join", comment: "")
    }
    
    @IBAction func attend(sender: UIButton) {
        guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
            return
        }

        ParseHelper.changeStateOfEvent(event,
                                       toJoined: attendState == .Join,
                                       completion: nil)

        if attendState == .Join {
            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
            blurryAlertViewController.modalPresentationStyle = .CurrentContext

            blurryAlertViewController.aboutText = NSLocalizedString("Your request has been sent.", comment: "")
            blurryAlertViewController.messageText = NSLocalizedString("We will notify you of the outcome.", comment: "")

            self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
        }

        switch attendState {
        case .Pending:
            attendState = .Leave
        case .Leave:
            attendState = .Join
        case .Join:
            attendState = .Pending
        default:
            break
        }

        //TODO: Update ListEventsVC
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

    //MARK: - Setup UI
    func updateAttendUI() {
        guard let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId,
            groupID = event.objectId else {
                return
        }

        let isAttendedToGroup = event.attendeeIDs.contains(currentUserID)

        if ParseHelper.sharedInstance.currentUser == event.owner || event.attendeeIDs.count >= event.limit {
            attendState = .Hidden
        } else if ParseHelper.sharedInstance.currentUser?.pendingGroupIDs.contains(groupID) == true {
            attendState = .Pending
        } else if isAttendedToGroup {
            attendState = .Leave
        } else {
            attendState = .Join
        }

        descr.hidden = !isAttendedToGroup
    }

    //MARK: - EventChangeDelegate
    
    func eventCreated(event:Event) {
        handleEventUpdate(event)
    }

    func eventChanged(event: Event) {
        handleEventUpdate(event)
    }

    func eventRemoved(event: Event) {
        delegate?.eventRemoved(event)
    }

    func handleEventUpdate(event: Event) {
        self.event = event
        update()
        delegate?.eventChanged(event)
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
