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

final class GroupDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate, GroupCreationDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var attendeesButtons: UICollectionView?
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var photo: UIImageView?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var location: UIButton?
    @IBOutlet weak var attendButton: UIButton?
    @IBOutlet weak var attendButtonHeight: NSLayoutConstraint?
    @IBOutlet weak var distance: UILabel?
    @IBOutlet weak var chatButton: UIButton?
    @IBOutlet weak var detailsButton: UIButton?
    @IBOutlet weak var author: UIButton?
    @IBOutlet weak var detailsUnderline: UIView?
    @IBOutlet weak var chatUnderline: UIView?
    @IBOutlet weak var messagesContainer: UIView?
    @IBOutlet weak var eventsContainer: UIView?
    @IBOutlet weak var members: UILabel?
    @IBOutlet weak var descr: UITextView?
    @IBOutlet weak var switherPlaceholderTopSpace: NSLayoutConstraint?

    private var currentLocation: CLLocation?
    private var attendees:[User] = [] {
        didSet {
            //The ommited member is the group owner
            members?.text = attendees.count == 0 ? "1 member".localized : "\(attendees.count + 1) members".localized
        }
    }

    var group: Category?
    var selectedCategoriesData: [Category]! = []
    var updatedStatusInGroup: (() -> Void)?

    weak var delegate: GroupChangeDelegate!

    private var attendState: AttendState = .Hidden {
        didSet {
            attendButton?.hidden = attendState == .Hidden
            attendButtonHeight?.constant = attendState == .Hidden ? 0 : 35

            switch (attendState) {
            case .Pending:
                attendButton?.setTitle(NSLocalizedString("Pending...", comment: ""), forState: .Normal)
                attendButton?.backgroundColor = .appOrangeColor()

            case .Join:
                attendButton?.setTitle(NSLocalizedString("Join Group", comment: ""), forState: .Normal)
                attendButton?.backgroundColor = .appBlackColor()

            case .Leave:
                attendButton?.setTitle(NSLocalizedString("Leave", comment: ""), forState: .Normal)
                attendButton?.backgroundColor = .appBlackColor()

            default:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = ""

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(updateAttendUI),
                                                         name: Constants.groupPendingStatusChangedNotification,
                                                         object: nil)

        chatButton?.enabled = false

        attendState = .Hidden

        switherPlaceholderTopSpace?.constant = view.bounds.width / 160 * 91

        if let messagesVC = self.storyboard?.instantiateViewControllerWithIdentifier(MessagesTableViewController.storyboardID) as? MessagesTableViewController {
            messagesVC.group = group

            addChildViewController(messagesVC)
            messagesContainer?.addSubview(messagesVC.view)

            messagesVC.view.translatesAutoresizingMaskIntoConstraints = false
            messagesContainer?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : messagesVC.view]))
            messagesContainer?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : messagesVC.view]))

            messagesVC.didMoveToParentViewController(self)
        }

        if let eventsListVC = UIStoryboard.main()?.instantiateViewControllerWithIdentifier(ListEventsViewController.storyboardID) as? ListEventsViewController {
            eventsListVC.eventsData = []
            ParseHelper.queryEventsForCategories(ParseHelper.sharedInstance.currentUser!, categories: selectedCategoriesData, block: { result, error in
                guard let events = result else {
                    if let error = error {
                        MessageToUser.showDefaultErrorMessage(error.localizedDescription)
                    }
                    return
                }

                eventsListVC.reloadAll(events)
            })

            addChildViewController(eventsListVC)
            eventsContainer?.addSubview(eventsListVC.view)

            eventsListVC.view.translatesAutoresizingMaskIntoConstraints = false
            eventsContainer?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : eventsListVC.view]))
            eventsContainer?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view" : eventsListVC.view]))

            eventsListVC.didMoveToParentViewController(self)
        }

        attendeesButtons?.registerNib(GroupsViewCell.nib, forCellWithReuseIdentifier: GroupsViewCell.reuseIdentifier)
        attendeesButtons?.delegate = self
        attendeesButtons?.dataSource = self

        descr?.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)

        if ParseHelper.sharedInstance.currentUser?.objectId == group?.owner?.objectId {
            let editdone = UIBarButtonItem(image:UIImage(named: "edit_icon"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(GroupDetailsViewController.editGroup(_:)))
            editdone.tintColor = Color.PrimaryActiveColor
            self.navigationItem.setRightBarButtonItem(editdone, animated: false)
        }

        ParseHelper.fetchObject(group, completion: { [weak self] fetchedObject, error in
            guard let fetchedObject = fetchedObject, fetchedGroup = Category(object: fetchedObject) where error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                return
            }

            self?.group = fetchedGroup
            self?.location?.hidden = fetchedGroup.location == nil

            ParseHelper.fetchUsers(fetchedGroup.attendeeIDs.filter({ $0 != fetchedGroup.owner?.objectId }), completion: { fetchedUsers, error in
                guard let fetchedUsers = fetchedUsers where error == nil else {
                    MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                    return
                }

                self?.attendees = fetchedUsers
                self?.attendeesButtons?.reloadData()

                if ParseHelper.sharedInstance.currentUser == fetchedGroup.owner {
                    self?.attendState = .Hidden
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
                        self?.author?.sd_setImageWithURL(avatarURL, forState: .Normal, completed: { (_, error, _, _) in
                            if error != nil {
                                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                            }
                        })
                    } else {
                        self?.author?.setImage(UIImage(named: "upload_pic"), forState: .Normal)
                    }
                })

                self?.chatButton?.enabled = true

                self?.update()
            })
            })
        switchToDetails(true)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateAttendUI()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func update() {
        if let locationPF = self.group?.location, let currentLocation = self.currentLocation {
            let distanceBetween: CLLocationDistance = CLLocation(latitude: locationPF.latitude, longitude: locationPF.longitude).distanceFromLocation(currentLocation)
            let distanceStr = String(format: "%.2f", distanceBetween/1000)
            self.distance?.text = distanceBetween > 0 ? "\(distanceStr)km" : nil
            CLLocation(latitude: locationPF.latitude, longitude: locationPF.longitude).getLocationString(nil, button: location, timezoneCompletion: nil)
        } else {

        }

        self.title  = self.group?.name
        self.name?.text = self.group?.name
        descr?.text = group?.summary

        if let photoFile = group?.photo,
            photoURLString = photoFile.url,
            photoURL = NSURL(string: photoURLString) {
            photo?.sd_setImageWithURL(photoURL)
        }

        updateAttendUI()
    }

    func updateAttendUI() {
        guard let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId,
            groupID = group?.objectId else {
                return
        }

        ParseHelper.fetchObject(group, completion: { [weak self] fetchedObject, error in
            guard let fetchedObject = fetchedObject, fetchedGroup = Category(object: fetchedObject) where error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
                return
            }
            self?.group = fetchedGroup

            let isAttendedToGroup = self?.group?.attendeeIDs.contains(currentUserID)

            if ParseHelper.sharedInstance.currentUser == self?.group?.owner {
                self?.attendState = .Hidden
            } else if ParseHelper.sharedInstance.currentUser?.pendingGroupIDs.contains(groupID) == true {
                self?.attendState = .Pending
            } else if isAttendedToGroup ?? false {
                self?.attendState = .Leave
            } else {
                self?.attendState = .Join
            }

            self?.descr?.hidden = isAttendedToGroup ?? false
            })
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
            cell.image?.sd_setImageWithURL(photoURL)
        } else {
            cell.image?.image = UIImage(named: "upload_pic")
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

    @IBAction func attend(sender: UIButton) {
        guard let blurryAlertViewController = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("BlurryAlertViewController") as? BlurryAlertViewController,
            let group = group else {
                return
        }

        if attendState == .Pending || attendState == .Leave {
            attendState = .Join
        } else if attendState == .Join {
            attendState = group.isPrivate ? .Pending : .Leave
        }

        ParseHelper.changeStateOfCategory(group,
                                          toJoined: attendState == .Leave || attendState == .Pending,
                                          completion: nil)
        updatedStatusInGroup?()

        if attendState == .Pending {
            blurryAlertViewController.action = BlurryAlertViewController.BUTTON_OK
            blurryAlertViewController.modalPresentationStyle = .CurrentContext
            blurryAlertViewController.aboutText = "Your request has been sent.".localized
            blurryAlertViewController.messageText = "We will notify you of the outcome.".localized

            self.presentViewController(blurryAlertViewController, animated: true, completion: nil)
        }
    }

    @IBAction func chat(sender: AnyObject) {
        if ParseHelper.sharedInstance.currentUser != nil {
            if (attendees.count > 0) {
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

        chatUnderline?.hidden = true
        detailsUnderline?.hidden = false
        messagesContainer?.hidden = true
        eventsContainer?.hidden = false

        switherPlaceholderTopSpace?.constant = self.view.bounds.width / 160 * 91
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func switchToChat(sender: AnyObject) {
        guard let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId, let groupOwner = group?.owner?.objectId
            where (group?.attendeeIDs.contains(currentUserID) == true || groupOwner == currentUserID ) else {
                MessageToUser.showMessage("Denied".localized, textId: "You must be attended to this group".localized)
                return
        }

        chatUnderline?.hidden = false
        detailsUnderline?.hidden = true
        messagesContainer?.hidden = false
        eventsContainer?.hidden = true
        switherPlaceholderTopSpace?.constant = 0

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
        var messageBody = "Hi, please check this group \"Group\".\n\nhttp://friendzi.io/"

        if let group = group {
            messageBody = "Hi, please check this group \"\(group.name)\".\n\nhttp://friendzi.io/"
        }

        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self

        mailComposerVC.setSubject(emailTitle)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)

        return mailComposerVC
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email".localized,
                                             message: "Your device could not send e-mail. Please check e-mail configuration and try again.".localized,
                                             delegate: self,
                                             cancelButtonTitle: "OK".localized)
        sendMailErrorAlert.show()
    }

    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func authorProfile(sender: AnyObject) {
        guard let userProfileViewController = UIStoryboard.profileTab()?.instantiateViewControllerWithIdentifier("UserProfileViewController") as? UserProfileViewController else {
            return
        }

        userProfileViewController.user = group?.owner

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
        guard let mapLatitute = group?.location?.latitude, let mapLongitude = group?.location?.longitude else {
            return
        }

        let latitute:CLLocationDegrees = mapLatitute
        let longitute:CLLocationDegrees = mapLongitude
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        if let name = group?.name {
            mapItem.name = "\(name)"
        }
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
