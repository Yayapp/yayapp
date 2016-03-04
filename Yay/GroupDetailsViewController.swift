//
//  GroupDetailsViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 12.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit
import MessageUI


protocol GroupChangeDelegate : NSObjectProtocol {
    func groupCreated(group:Category)
    func groupChanged(group:Category)
    func groupRemoved(group:Category)
}
class GroupDetailsViewController: UIViewController, UIPopoverPresentationControllerDelegate, GroupChangeDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var group:Category!
    var attendees:[PFUser] = []
    var delegate:GroupChangeDelegate!
    var currentLocation:CLLocation!
    var selectedCategoriesData:[Category]! = []
    var report:UIBarButtonItem!
    
    @IBOutlet weak var attendeesButtons: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var attendButton: UIButton!
    
    @IBOutlet weak var distance: UILabel!
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    
    @IBOutlet weak var author: UIButton!
    
    @IBOutlet weak var detailsUnderline: UIView!
    
    @IBOutlet weak var chatUnderline: UIView!
    
    @IBOutlet weak var messagesContainer: UIView!
    @IBOutlet weak var eventsContainer: UIView!
    
    @IBOutlet weak var members: UILabel!
    
    @IBOutlet weak var descr: UITextView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendeesButtons.delegate = self
        attendeesButtons.dataSource = self
        
        descr.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        members.text = "\(group.attendees.count) members"
        
        if(PFUser.currentUser()?.objectId == group.owner?.objectId) {
            
            let invite = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("invite:"))
            
            self.navigationItem.setRightBarButtonItem(invite, animated: false)
            
            cancelButton.hidden = false
            editButton.hidden = false
        } else {
            if let user = PFUser.currentUser() {
                ParseHelper.countReports(group,user: user, completion: {
                    count in
                    if count == 0 {
                        self.report = UIBarButtonItem(image:UIImage(named: "reporticon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("reportButtonTapped:"))
                        self.navigationItem.setRightBarButtonItem(self.report, animated: false)
                    }
                })
            } 
        }
        
        
        group.fetchInBackgroundWithBlock({
            result, error in
            
            if error == nil {
                self.attendees = self.group.attendees.filter({$0.objectId != self.group.owner?.objectId})
                
                let currentPFLocation = PFUser.currentUser()!.objectForKey("location") as! PFGeoPoint
                self.currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
                
                
                
                self.group.owner?.fetchIfNeededInBackgroundWithBlock({
                    result, error in
                    if error == nil {
                        if let avatar = self.group.owner?["avatar"] as? PFFile {
                            
                            avatar.getDataInBackgroundWithBlock({
                                (data:NSData?, error:NSError?) in
                                if(error == nil) {
                                    let image = UIImage(data:data!)
                                    self.author.setImage(image, forState: .Normal)
                                } else {
                                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                                }
                            })
                        } else {
                            self.author.setImage(UIImage(named: "upload_pic"), forState: .Normal)
                        }
                    } else {
                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                    }
                })
                
                
                let attendedThisEvent = !(self.group.attendees.filter({$0.objectId == PFUser.currentUser()?.objectId}).count == 0)
                
                if(PFUser.currentUser()?.objectId != self.group.owner?.objectId) {
                    
                    if !attendedThisEvent {
                        
                        self.chatButton.enabled = false
                        
                        ParseHelper.getUserRequests(self.group, user: PFUser.currentUser()!, block: {
                            result, error in
                            if (error == nil) {
                                if (result == nil || result!.isEmpty){
                                    self.attendButton.hidden = false
                                } else {
                                    self.attendButton.hidden = true
                                }
                            } else {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        self.descr.hidden = true
                        self.attendButton.hidden = true
                    }
                }
                self.update()
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        switchToDetails(true)
    }
    
    
    func update() {
        if let locationPF = self.group.location {
            let distanceBetween: CLLocationDistance = CLLocation(latitude: locationPF.latitude, longitude: locationPF.longitude).distanceFromLocation(self.currentLocation)
            let distanceStr = String(format: "%.2f", distanceBetween/1000)
            self.distance.text = "\(distanceStr)km"
            CLLocation(latitude: locationPF.latitude, longitude: locationPF.longitude).getLocationString(nil, button: location, timezoneCompletion: nil)
        } else {
            
        }
        self.title  = self.group.name
        self.name.text = self.group.name
        self.photo.file = self.group.photo
        self.photo.loadInBackground()
        
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return group.attendees.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GroupsViewCell
        
        group.attendees[indexPath.row].fetchIfNeededInBackgroundWithBlock({
            result, error in
            if error == nil {
                if let attendeeAvatar = self.group.attendees[indexPath.row]["avatar"] as? PFFile {
                    cell.image.file = attendeeAvatar
                    cell.image.loadInBackground()
                } else {
                    cell.image.image = UIImage(named: "upload_pic")
                }
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("profile", sender: group.attendees[indexPath.row])
    }
    
    @IBAction func attend(sender: UIButton) {
        if let user = PFUser.currentUser() {
            spinner.startAnimating()
            group.fetchIfNeededInBackgroundWithBlock({
                (result, error) in
                
                let requestACL:PFACL = PFACL()
                requestACL.publicWriteAccess = true
                requestACL.publicReadAccess = true
                let request = Request()
                request.group = self.group
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
            //            }
        } else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func chat(sender: AnyObject) {
        if PFUser.currentUser() != nil {
            if (attendees.count>0) {
                let controller: MessagesTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MessagesTableViewController") as! MessagesTableViewController
                controller.group = group
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
        eventsContainer.hidden = false
        if(PFUser.currentUser()?.objectId == group.owner?.objectId) {
            cancelButton.hidden = false
            editButton.hidden = false
        }
    }
    
    @IBAction func switchToChat(sender: AnyObject) {
        chatUnderline.hidden = false
        detailsUnderline.hidden = true
        messagesContainer.hidden = false
        eventsContainer.hidden = true
        cancelButton.hidden = true
        editButton.hidden = true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.None
    }
    
    
    @IBAction func invite(sender: AnyObject) {
        let map = self.storyboard!.instantiateViewControllerWithIdentifier("InviteViewController") as! InviteViewController
        
        map.modalPresentationStyle = UIModalPresentationStyle.Popover
        map.preferredContentSize = CGSizeMake(self.view.frame.width, 300)
        map.group = group
        
        let detailPopover: UIPopoverPresentationController = map.popoverPresentationController!
        detailPopover.delegate = self
        detailPopover.barButtonItem = sender as? UIBarButtonItem
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Up
        
        presentViewController(map,
            animated: true, completion:nil)
    }
    
    @IBAction func authorProfile(sender: AnyObject) {
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = group.owner
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func attendeeProfile(sender: AnyObject) {
        let userProfileViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        userProfileViewController.user = attendees[sender.tag]
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    func groupChanged(group: Category) {
        self.group = group
        update()
        if self.delegate != nil {
            delegate.groupChanged(group)
        }
    }
    func groupCreated(group: Category){}
    func groupRemoved(group:Category){}
    
    @IBAction func cancelGroup(sender: AnyObject) {
        
        let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_DELETE
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.messageText = "Sorry, are you sure you want to delete this group?"
        blurryAlertViewController.hasCancelAction = true
        blurryAlertViewController.group = group
        blurryAlertViewController.completion = {
            if self.delegate != nil {
                self.delegate.groupRemoved(self.group)
            }
            self.navigationController?.popViewControllerAnimated(false)
        }
        self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
    }
    
    @IBAction func editGroup(sender: AnyObject){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CreateGroupViewController") as! CreateGroupViewController
        vc.group = group
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openMapForPlace(sender: AnyObject) {
        
        let latitute:CLLocationDegrees =  (group.location?.latitude)!
        let longitute:CLLocationDegrees =  (group.location?.longitude)!
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(group.name)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    @IBAction func reportButtonTapped(sender: AnyObject) {
        let blurryAlertViewController = self.storyboard!.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as! BlurryAlertViewController
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.hasCancelAction = true
        blurryAlertViewController.messageText = "You are about to flag this group for inappropriate content. Are you sure?"
        blurryAlertViewController.completion = {
            let report = Report()
            report.group = self.group
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
            vc.group = group
        } else if(segue.identifier == "events") {
            let vc = (segue.destinationViewController as! ListEventsViewController)
            vc.eventsData = []
            ParseHelper.queryEventsForCategories(PFUser.currentUser(), categories: selectedCategoriesData, block: {
                result, error in
                if error == nil {
                    vc.reloadAll(result!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else if(segue.identifier == "profile") {
            let vc = (segue.destinationViewController as! UserProfileViewController)
            vc.user = sender as! PFUser
        }
    }
    
}
