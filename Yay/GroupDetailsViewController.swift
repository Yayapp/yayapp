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
    func groupChanged(group:Category)
    func groupRemoved(group:Category)
}
class GroupDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate, GroupCreationDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var group:Category!
    var attendees:[User] = []
    var delegate:GroupChangeDelegate!
    var currentLocation:CLLocation!
    var selectedCategoriesData:[Category]! = []
    
    var updatedStatusInGroup: (() -> Void)?
    
    @IBOutlet weak var attendeesButtons: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var attendButtonHeight: NSLayoutConstraint!
    
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
    @IBOutlet weak var switherPlaceholderTopSpace: NSLayoutConstraint!

    var attendedThisGroup: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()

        chatButton.enabled = false

        switherPlaceholderTopSpace.constant = view.bounds.width / 160 * 91
        
        if let messagesVC = UIStoryboard.main()?.instantiateViewControllerWithIdentifier(MessagesTableViewController.storyboardID) as? MessagesTableViewController {
            messagesVC.group = group
            addChildViewController(messagesVC)
            messagesVC.didMoveToParentViewController(self)
            messagesContainer.addSubview(messagesVC.view)
        }

        if let eventsListVC = UIStoryboard.main()?.instantiateViewControllerWithIdentifier(ListEventsViewController.storyboardID) as? ListEventsViewController {
            eventsListVC.eventsData = []
            ParseHelper.queryEventsForCategories(ParseHelper.sharedInstance.currentUser!, categories: selectedCategoriesData, block: {
                result, error in
                if error == nil {
                    eventsListVC.reloadAll(result!)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })

            addChildViewController(eventsListVC)
            eventsListVC.didMoveToParentViewController(self)
            eventsContainer.addSubview(eventsListVC.view)
        }

        attendeesButtons.registerNib(GroupsViewCell.nib, forCellWithReuseIdentifier: GroupsViewCell.reuseIdentifier)
        attendeesButtons.delegate = self
        attendeesButtons.dataSource = self
        
        descr.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
        
        members.text = "\(group.attendeeIDs.count) members"
        
        if(ParseHelper.sharedInstance.currentUser?.objectId == group.owner?.objectId) {
            let editdone = UIBarButtonItem(image:UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("editGroup:"))
            editdone.tintColor = Color.PrimaryActiveColor
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
            //            attend.setImage(UIImage(named: "cancelevent_button"), forState: .Normal)
        }

        ParseHelper.fetchObject(group, completion: { [weak self] fetchedObject, error in
            guard let fetchedObject = fetchedObject,
                fetchedGroup = Category(object: fetchedObject)
                where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
            }

            self?.group = fetchedGroup

            self?.location.hidden = fetchedGroup.location == nil

            ParseHelper.fetchUsers(fetchedGroup.attendeeIDs.filter({$0 != fetchedGroup.owner?.objectId}), completion: { (fetchedUsers, error) in
                guard let fetchedUsers = fetchedUsers where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                    return
                }

                self?.attendees = fetchedUsers
                self?.attendeesButtons.reloadData()

                if let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId {
                    self?.attendButton.setTitle(self?.attendTitle(fetchedGroup.attendeeIDs.contains(currentUserID)), forState: .Normal)
                    let isAttendButtonHidden = currentUserID == fetchedGroup.owner?.objectId
                    self?.attendButton.hidden = isAttendButtonHidden
                    self?.attendButtonHeight.constant = isAttendButtonHidden ? 0 : 35
                }

                let currentLocation = ParseHelper.sharedInstance.currentUser!.location
                self?.currentLocation = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)

                ParseHelper.fetchObject(fetchedGroup.owner, completion: {
                    result, error in
                    guard let fetchedObject = result,
                        fetchedOwner = User(object: fetchedObject) where error == nil else {
                            MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                            return
                    }

                    if let avatarURLString = fetchedOwner.avatar?.url,
                        avatarURL = NSURL(string: avatarURLString) {
                        self?.author.sd_setImageWithURL(avatarURL, forState: .Normal, completed: { (_, error, _, _) in
                            if error != nil {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        self?.author.setImage(UIImage(named: "upload_pic"), forState: .Normal)
                    }
                })

                self?.attendedThisGroup = !(fetchedGroup.attendeeIDs.filter({$0 == ParseHelper.sharedInstance.currentUser?.objectId}).count == 0) || ParseHelper.sharedInstance.currentUser?.objectId == fetchedGroup.owner!.objectId
                self?.chatButton.enabled = true

                if(ParseHelper.sharedInstance.currentUser?.objectId != fetchedGroup.owner?.objectId) {

                    if self?.attendedThisGroup != true {
                        ParseHelper.getUserRequests(fetchedGroup, user: ParseHelper.sharedInstance.currentUser!, block: {
                            result, error in
                            if (error == nil) {
                                if (result == nil || result!.isEmpty){
                                    self?.attendButton.hidden = false
                                } else {
                                    self?.attendButton.hidden = true
                                }
                            } else {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        self?.descr.hidden = true
                        self?.attendButton.hidden = true
                    }
                }
                self?.update()
            })
            })
        switchToDetails(true)
    }
    
    func update() {
        if let locationPF = self.group.location {
            let distanceBetween: CLLocationDistance = CLLocation(latitude: locationPF.latitude, longitude: locationPF.longitude).distanceFromLocation(self.currentLocation)
            let distanceStr = String(format: "%.2f", distanceBetween/1000)
            self.distance.text = distanceBetween > 0 ? "\(distanceStr)km" : nil
            CLLocation(latitude: locationPF.latitude, longitude: locationPF.longitude).getLocationString(nil, button: location, timezoneCompletion: nil)
        } else {
            
        }
        self.title  = self.group.name
        self.name.text = self.group.name

        if let photoFile = group.owner?.avatar,
            photoURLString = photoFile.url,
            photoURL = NSURL(string: photoURLString) {
            photo.sd_setImageWithURL(photoURL)
        }
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attendees.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(GroupsViewCell.reuseIdentifier, forIndexPath: indexPath) as? GroupsViewCell else {
            return UICollectionViewCell()
        }

            if let attendeeAvatar = self.attendees[indexPath.row].avatar,
                photoURLString = attendeeAvatar.url,
                photoURL = NSURL(string: photoURLString) {
                cell.image.sd_setImageWithURL(photoURL)
            } else {
                cell.image.image = UIImage(named: "upload_pic")
            }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let profileVC = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        profileVC.user = attendees[indexPath.row]

        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func attendTitle(isJoined: Bool) -> String {
        return isJoined ? NSLocalizedString("Leave", comment: "") : NSLocalizedString("Join", comment: "")
    }
    
    @IBAction func attend(sender: UIButton) {
        guard let user = ParseHelper.sharedInstance.currentUser else {
            return
        }

        if group.isPrivate {
            attendButton.hidden = true

            ParseHelper.requestJoinGroup(group, completion: nil)

            guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
                return
            }

            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
            blurryAlertViewController.modalPresentationStyle = .CurrentContext

            blurryAlertViewController.aboutText = NSLocalizedString("Your request has been sent.", comment: "")
            blurryAlertViewController.messageText = NSLocalizedString("We will notify you of the outcome.", comment: "")

            presentViewController(blurryAlertViewController, animated: true, completion: nil)
        } else {
            let isJoined = attendees.contains(user)
            self.attendButton.setTitle(attendTitle(!isJoined), forState: .Normal)

            ParseHelper.changeStateOfCategory(group, toJoined: true, completion: { [weak self] _, error in
                guard error == nil else {
                    MessageToUser.showDefaultErrorMessage(NSLocalizedString("Error occurred in changing your status in current group.", comment: ""))

                    return
                }

                self?.updatedStatusInGroup?()
                })
        }
    }

    @IBAction func chat(sender: AnyObject) {
        if ParseHelper.sharedInstance.currentUser != nil {
            if (attendees.count>0) {
                guard let controller: MessagesTableViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("MessagesTableViewController") as? MessagesTableViewController else {
                    return
                }

                controller.group = group
                self.navigationController!.pushViewController(controller, animated: true)
            } else {
                MessageToUser.showDefaultErrorMessage("There are no attendees yet.")
            }
        } else {
            guard let vc = UIStoryboard.auth()?.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController else {
                return
            }

            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchToDetails(sender: AnyObject) {
        view.endEditing(true)

        chatUnderline.hidden = true
        detailsUnderline.hidden = false
        messagesContainer.hidden = true
        eventsContainer.hidden = false

        switherPlaceholderTopSpace.constant = self.view.bounds.width / 160 * 91
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func switchToChat(sender: AnyObject) {
        guard attendedThisGroup == true else {
            MessageToUser.showMessage(NSLocalizedString("Denied", comment: ""),
                                      textId: NSLocalizedString("You must be attended to this group", comment: ""))

            return
        }

        chatUnderline.hidden = false
        detailsUnderline.hidden = true
        messagesContainer.hidden = false
        eventsContainer.hidden = true

        switherPlaceholderTopSpace.constant = 0
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }

    
    
    @IBAction func invite(sender: AnyObject) {
        if (ParseHelper.sharedInstance.currentUser != nil) {
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
        let messageBody = "Hi, please check this group \"\(group.name)\".\n\nhttp://friendzi.io/"
        
        
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

        userProfileViewController.user = group.owner
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    @IBAction func attendeeProfile(sender: AnyObject) {
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        userProfileViewController.user = attendees[sender.tag]
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    func groupCreated(group:Category) {
        self.group = group
        update()
        if self.delegate != nil {
            delegate.groupChanged(group)
        }
    }
    
    @IBAction func editGroup(sender: AnyObject) {
        guard let vc = UIStoryboard.groupsTab()?.instantiateViewControllerWithIdentifier("CreateGroupViewController") as? CreateGroupViewController else {
            return
        }

        vc.isEditMode = true
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
        guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController else {
            return
        }
        
        blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
        blurryAlertViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        blurryAlertViewController.messageText = "You are about to flag this group for inappropriate content. Are you sure?"
        blurryAlertViewController.completion = {
            let report = Report()
            report.group = self.group
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
}
