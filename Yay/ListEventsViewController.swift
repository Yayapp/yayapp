//
//  ListEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

protocol ListEventsDelegate : NSObjectProtocol {
    func madeEventChoice(event: Event)
}

class ListEventsViewController: EventsViewController, UITableViewDataSource, UITableViewDelegate {
    static let storyboardID = "ListEventsViewController"
    
    var eventsFirst:[Event]?
    var currentTitle:String?
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation?
    var introPopover: WYPopoverController?
    
    
    @IBOutlet weak var events: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ListEventsViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ListEventsViewController.handleInviteToEvent),
                                                         name: Constants.userInvitedToEventNotification,
                                                         object: nil)

        guard let currentUser = ParseHelper.sharedInstance.currentUser
            where currentUser.avatar != nil && currentUser.gender != nil else {
                if let completeProfileVC = UIStoryboard(name: "Auth", bundle: nil).instantiateViewControllerWithIdentifier(CompleteProfileViewController.storyboardID) as? CompleteProfileViewController {
                    completeProfileVC.dismissButtonHidden = false
                    completeProfileVC.onNextButtonPressed = {
                        (UIApplication.sharedApplication().delegate as? AppDelegate)?.gotoMainTabBarScreen()
                    }
                    presentViewController(completeProfileVC, animated: false, completion: nil)
                }

                return
        }

        dateFormatter.dateFormat = "EEE dd MMM '@' H:mm"
        title = currentTitle
        
        if let introController = self.storyboard?.instantiateViewControllerWithIdentifier(IntroViewController.storyboardID) as? IntroViewController {
            self.introPopover = WYPopoverController(contentViewController: introController)
            self.introPopover?.beginThemeUpdates()
            self.introPopover?.theme.overlayColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            self.introPopover?.endThemeUpdates()
            
            if let tabbarController = self.tabBarController,
                let controllersCount = tabbarController.viewControllers?.count
            {
                let elementWidth = CGRectGetWidth(self.view.bounds) / CGFloat(controllersCount)
                
                self.introPopover?.presentPopoverFromRect(CGRectMake(elementWidth / 2, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(tabbarController.tabBar.bounds), 1, 1), inView: self.view, permittedArrowDirections: .Down, animated: false, options: .Fade)
            }
        }

        guard let currentPFLocation = currentUser.location else {
            return
        }

        currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)

        events.registerNib(EventsTableViewCell.nib, forCellReuseIdentifier: EventsTableViewCell.reuseIdentifier)
        events.delegate = self
        events.dataSource = self
        
        if let events = eventsFirst {
            reloadAll(events)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard let invitedEventID = DataProxy.sharedInstance.invitedEventID else {
            return
        }

        openInvitedEventDetails(invitedEventID)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userInvitedToEventNotification,
                                                            object: nil)
    }

    func openInvitedEventDetails(eventID: String) {
        guard let invitedEventID = DataProxy.sharedInstance.invitedEventID,
            eventDetailsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EventDetailsViewController") as? EventDetailsViewController else {
                return
        }

        eventDetailsVC.delegate = self
        SVProgressHUD.show()

        ParseHelper.fetchEvent(invitedEventID, completion: { [weak self] (fetchedObject, error) in
            SVProgressHUD.dismiss()

            guard let fetchedEvent = fetchedObject as? Event
                where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
            }

            eventDetailsVC.event = fetchedEvent
            self?.navigationController?.pushViewController(eventDetailsVC, animated: true)

            DataProxy.sharedInstance.invitedEventID = nil
            })
    }

    override func reloadAll(eventsList:[Event]) {
        eventsData = eventsList
        events.reloadData()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventsData.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clearColor()

        return header
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = events.dequeueReusableCellWithIdentifier(EventsTableViewCell.reuseIdentifier) as! EventsTableViewCell
        let event:Event! = eventsData[indexPath.section]
        let cllocation = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude)
        let distanceBetween: CLLocationDistance = cllocation.distanceFromLocation(currentLocation!)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        let attendeeButtons:[UIButton]! = [cell.attended1, cell.attended2, cell.attended3, cell.attended4]
        
        cell.title.text = event.name
        
        cllocation.getLocationString(cell.location, button: nil, timezoneCompletion: nil)

        cell.date.text = dateFormatter.stringFromDate(event.startDate)
        cell.howFar.text = distanceBetween > 0 ? "\(distanceStr)km" : nil
        
        if let photoURLString = event.photo.url,
            photoURL = NSURL(string: photoURLString) {
            cell.picture.sd_setImageWithURL(photoURL)
        }

        ParseHelper.fetchObject(event.owner, completion: { (result, error) in
            if error == nil {
                if let avatarURLString = event.owner!.avatar?.url,
                    avatarURL = NSURL(string: avatarURLString) {
                    cell.author.sd_setImageWithURL(avatarURL, forState: .Normal)
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })

        cell.author.tag = indexPath.section
        cell.author.addTarget(self, action: #selector(ListEventsViewController.authorProfile(_:)), forControlEvents: .TouchUpInside)

        let allAttendeeIDsWithoutOwner = event.attendeeIDs.filter({$0 != event.owner!.objectId})
        let attendeeIDs = allAttendeeIDsWithoutOwner[0..<min(allAttendeeIDsWithoutOwner.count, attendeeButtons.count)]
        
        for (index, attendeeID) in attendeeIDs.enumerate() {
            let attendeeButton = attendeeButtons[index]

            attendeeButton.addTarget(self, action: "attendeeProfile:", forControlEvents: .TouchUpInside)

            attendeeButton.tag = indexPath.section
            attendeeButton.titleLabel?.tag = index

            ParseHelper.fetchUser(attendeeID, completion: {
                result, error in
                if error == nil {
                    if let attendeeAvatarURLString = result!.avatar?.url,
                        attendeeAvatarURL = NSURL(string: attendeeAvatarURLString) {
                        attendeeButton.sd_setImageWithURL(attendeeAvatarURL, forState: .Normal, completed: { (_, error, _, _) in
                            guard error == nil else {
                                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                                return
                            }

                            attendeeButton.hidden = false
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
        
        if attendeeButtons.count > attendeeIDs.count && event.owner!.objectId != ParseHelper.sharedInstance.currentUser?.objectId && attendeeIDs.count < (event.limit-1) && !allAttendeeIDsWithoutOwner.contains(ParseHelper.sharedInstance.currentUser!.objectId!)
        {
            let attendeeButton = attendeeButtons[attendeeIDs.count]
            attendeeButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
            attendeeButton.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
            attendeeButton.setTitle("JOIN", forState: .Normal)
            attendeeButton.hidden = false
            attendeeButton.tag = indexPath.section
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(delegate != nil) {
            delegate!.madeEventChoice(eventsData[indexPath.section])
        } else {
            performSegueWithIdentifier("event_details", sender: indexPath)
        }
    }
    
    override func eventChanged(event:Event) {
        events.reloadData()
    }
    
    override func eventRemoved(event:Event) {
        eventsData = eventsData.filter({$0.objectId != event.objectId})
        events.reloadData()
    }
    
    @IBAction func join(sender: UIButton) {
        sender.hidden = true

        let event:Event! = eventsData[sender.tag]
        if let user = ParseHelper.sharedInstance.currentUser {
            ParseHelper.fetchObject(event, completion: {
                (result, error) in
                
                let requestACL = ObjectACL()
                requestACL.publicWriteAccess = true
                requestACL.publicReadAccess = true
                let request = Request()
                request.event = event
                request.attendee = user
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
            })
        } else {
            guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
                return
            }

            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func authorProfile(sender: AnyObject) {
        let event:Event! = eventsData[sender.tag]
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        userProfileViewController.userID = event.owner?.objectId
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func attendeeProfile(sender: UIButton) {
        let event:Event! = eventsData[sender.tag]
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        let allAttendeeIDsWithoutOwner = event.attendeeIDs.filter({ $0 != event.owner!.objectId })
        let attendeeIDs = allAttendeeIDsWithoutOwner[0..<min(allAttendeeIDsWithoutOwner.count, 4)]

        userProfileViewController.userID = attendeeIDs[(sender.titleLabel?.tag)!]
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "event_details") {
            if let indexPath = sender as? NSIndexPath {
                let vc = (segue.destinationViewController as! EventDetailsViewController)
                vc.event = eventsData[indexPath.section]
                vc.delegate = self
            }
        }
    }

    //MARK: - Notification Handlers
    func handleUserLogout() {
        eventsFirst?.removeAll()
        eventsData.removeAll()
        events.reloadData()
    }

    func handleInviteToEvent(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            eventID = userInfo["objectId"] as? String else {
                return
        }

        openInvitedEventDetails(eventID)
    }
}

