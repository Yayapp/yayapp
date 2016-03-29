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

    var eventsFirst:[Event]?
    var currentTitle:String?
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation?
    
    
    @IBOutlet weak var events: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE dd MMM '@' H:mm"
        
    
        
        if currentTitle != nil {
            title = currentTitle!
        }
        
            let currentPFLocation = PFUser.currentUser()!.objectForKey("location") as! PFGeoPoint
            currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
        
        events.registerNib(EventsTableViewCell.nib, forCellReuseIdentifier: EventsTableViewCell.reuseIdentifier)
        events.delegate = self
        events.dataSource = self
        
        if (eventsFirst != nil) {
            reloadAll(eventsFirst!)
        }
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
        let event:Event! = eventsData[indexPath.row]
        let cllocation = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude)
        let distanceBetween: CLLocationDistance = cllocation.distanceFromLocation(currentLocation!)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        let attendeeButtons:[UIButton]! = [cell.attended1, cell.attended2, cell.attended3, cell.attended4]
        
        cell.title.text = event.name
        
        cllocation.getLocationString(cell.location, button: nil, timezoneCompletion: nil)

        cell.date.text = dateFormatter.stringFromDate(event.startDate)
        cell.howFar.text = "\(distanceStr)km"
        
        cell.picture.file = event.photo
        cell.picture.loadInBackground()
        
        event.owner.fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                if let avatar = event.owner["avatar"] as? PFFile {
                    
                    avatar.getDataInBackgroundWithBlock({
                        (data:NSData?, error:NSError?) in
                        if(error == nil) {
                            let image = UIImage(data:data!)
                            cell.author.setImage(image, forState: .Normal)
                        } else {
                            MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                        }
                    })
                    
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
        let attendees:[PFUser] = event.attendees.filter({$0.objectId != event.owner.objectId})
        
        for (index, attendee) in attendees.enumerate() {
            let attendeeButton = attendeeButtons[index]

            attendeeButton.addTarget(self, action: "attendeeProfile:", forControlEvents: .TouchUpInside)
            attendeeButton.tag = indexPath.row
            attendeeButton.titleLabel?.tag = index
            
            attendee.fetchIfNeededInBackgroundWithBlock({
                result, error in
                if error == nil {
                    if let attendeeAvatar = attendee["avatar"] as? PFFile {
                        
                        attendeeAvatar.getDataInBackgroundWithBlock({
                            (data:NSData?, error:NSError?) in
                            if(error == nil) {
                                let image = UIImage(data:data!)
                                attendeeButton.setImage(image, forState: .Normal)
                                attendeeButton.hidden = false
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
        
        if attendeeButtons.count > attendees.count && event.owner.objectId != PFUser.currentUser()?.objectId && attendees.count < (event.limit-1){
            let attendeeButton = attendeeButtons[attendees.count]
            attendeeButton.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
            attendeeButton.setTitle("Join", forState: .Normal)
            attendeeButton.hidden = false
            attendeeButton.tag = indexPath.row
        }
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(delegate != nil) {
            delegate!.madeEventChoice(eventsData[indexPath.row])
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
        let event:Event! = eventsData[sender.tag]
        if let user = PFUser.currentUser() {
            event.fetchIfNeededInBackgroundWithBlock({
                (result, error) in
                
                let requestACL:PFACL = PFACL()
                requestACL.publicWriteAccess = true
                requestACL.publicReadAccess = true
                let request = Request()
                request.event = event
                request.attendee = user
                request.ACL = requestACL
                request.saveInBackground()
                
                sender.hidden = true
                
                let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
                blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
                blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
                blurryAlertViewController.aboutText = "Your request has been sent."
                blurryAlertViewController.messageText = "We will notify you of the outcome."
                self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
            })
        } else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func authorProfile(sender: AnyObject) {
        let event:Event! = eventsData[sender.tag]
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = event.owner
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func attendeeProfile(sender: UIButton) {
        let event:Event! = eventsData[sender.tag]
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = event.attendees[(sender.titleLabel?.tag)!]
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "event_details") {
            if let indexPath = sender as? NSIndexPath {
                let vc = (segue.destinationViewController as! EventDetailsViewController)
                vc.event = eventsData[indexPath.row]
                vc.delegate = self
            }
        }
    }
}

