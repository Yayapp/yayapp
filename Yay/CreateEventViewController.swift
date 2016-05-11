//
//  CreateEventViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: KeyboardAnimationHelper, ChooseLocationDelegate, CategoryPickerDelegate, ChooseEventPictureDelegate, WriteAboutDelegate, UIPopoverPresentationControllerDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

    var event:Event?
    var isEditMode = false
    
    let dateFormatter = NSDateFormatter()
    var longitude: Double?
    var latitude: Double?
    var chosenDate:NSDate?
    var chosenCategories:[Category]! = []
    var chosenPhoto: File?
    var delegate:EventChangeDelegate!
    var timeZone:NSTimeZone!
    var attendeesButtons:[UIButton]!=[]
    var descriptionText:String!=""
    
    var limitInt:Int=1
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var pickCategory: UIButton!
    @IBOutlet weak var eventPhoto: UIButton!
    @IBOutlet weak var dateTimeButton: UIButton!
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var descr: UIButton!

    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var author: UIButton!
    
    @IBOutlet weak var attendee1: UIButton!
    
    @IBOutlet weak var attendee2: UIButton!
    
    @IBOutlet weak var attendee3: UIButton!
    
    @IBOutlet weak var attendee4: UIButton!
    
    @IBOutlet weak var leftNavigationButton: UIButton!
    @IBOutlet weak var dimmingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(CreateEventViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)

        attendeesButtons = [attendee1, attendee2, attendee3, attendee4]
        
        pickCategory.layer.borderColor = UIColor.whiteColor().CGColor
        name.delegate = self
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"

        title = isEditMode ? NSLocalizedString("Edit Event", comment: "") : NSLocalizedString("Create Event", comment: "")
        leftNavigationButton.setTitle(NSLocalizedString("back", comment: ""), forState: .Normal)
        leftNavigationButton.hidden = event == nil
        createButton.setTitle(isEditMode ? NSLocalizedString("Save", comment: "") : NSLocalizedString("Create Event & Invite Friends", comment: ""), forState: .Normal)
        
        if event != nil {
            update()
        }

        if let avatarURLString = ParseHelper.sharedInstance.currentUser?.avatar?.url,
            avatarURL = NSURL(string: avatarURLString) {
            self.author.sd_setImageWithURL(avatarURL, forState: .Normal)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        guard DataProxy.sharedInstance.needsShowCreateEventTabHint else {
            return
        }

        dimmingView.hidden = false

        let titleImageView = UIImageView(image: UIImage(named: "logoInactive"))
        titleImageView.contentMode = .ScaleAspectFit
        titleImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        navigationItem.titleView = titleImageView

        if let popoverController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(PopoverViewController.storyboardID) as? PopoverViewController,
            let controllersCount = tabBarController?.viewControllers?.count {
            let elementWidth = CGRectGetWidth(view.bounds) / CGFloat(controllersCount)

            popoverController.arrowViewLeadingSpace = elementWidth * 3 - (elementWidth / 2) - 20
            popoverController.text = NSLocalizedString("Want to make something happen? Get a small group together for dinner, a festival, the museum, a show, drinks or a night out on the town?", comment: "")
            popoverController.submitButtonTitle = NSLocalizedString("Create Event (3/4)", comment: "")
            popoverController.onSubmitPressed = { [weak self] in
                self?.handlePopoverDismiss()
            }
            popoverController.onSkipPressed = { [weak self] in
                self?.handlePopoverDismiss()
            }

            DataProxy.sharedInstance.needsShowCreateEventTabHint = false
            presentViewController(popoverController, animated: false, completion: nil)
        }
    }

    func handlePopoverDismiss() {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        dimmingView.hidden = true
        navigationItem.titleView = nil
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
    }
    
    func update() {
        guard let eventID = event?.objectId else {
            return
        }

        ParseHelper.fetchEvent(eventID, completion: { result, error in
            if let fetchedEvent = result as? Event where error == nil {
                self.event = fetchedEvent

                self.title  = self.event!.name
                self.name.text = self.event!.name
                self.descriptionText = self.event!.summary
                self.descr.setTitle(self.event!.summary, forState: .Normal)
                self.limitInt = self.event!.limit - 1
                let dummyButton:UIButton = UIButton()
                dummyButton.tag = self.limitInt - 1
                self.changeLimit(dummyButton)
                self.madeCategoryChoice(self.event!.categories)
                self.madeEventPictureChoice(self.event!.photo, pickedPhoto: nil)
                self.madeDateTimeChoice(self.event!.startDate)
                self.madeLocationChoice(CLLocationCoordinate2D(latitude: self.event!.location.latitude, longitude: self.event!.location.longitude))
            } else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
            }
        })
    }
    
    @IBAction func openDateTimePicker(sender: AnyObject) {
        view.endEditing(true)

        let datePicker = ActionSheetDatePicker(title: nil, datePickerMode: .DateAndTime, selectedDate: NSDate(), doneBlock: {
            _, value, _ in
            guard let date = value as? NSDate else {
                return
            }

            self.madeDateTimeChoice(date)
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: self.view)

        datePicker.minimumDate = NSDate()
        datePicker.minuteInterval = 1
        datePicker.showActionSheetPicker()
    }
    
    @IBAction func openPhotoPicker(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ChooseEventPictureViewController") as? ChooseEventPictureViewController else {
            return
        }

        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openCategoryPicker(sender: AnyObject) {
        guard let vc = UIStoryboard.createEventTab()?.instantiateViewControllerWithIdentifier("CategoryPickerViewController") as? CategoryPickerViewController else {
            return
        }

        vc.categoryDelegate = self
        vc.selectedCategoriesData = chosenCategories
        
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func leftNavigationButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }

    func resetContent() {
        event = nil
        longitude = 0
        latitude = 0
        chosenDate = nil
        chosenCategories.removeAll()
        chosenPhoto = nil
        descriptionText = ""

        eventImage.image = nil
        pickCategory.setTitle(NSLocalizedString("Share with Group", comment: ""), forState: .Normal)
        dateTimeButton.setTitle(NSLocalizedString("Time & Date", comment: ""), forState: .Normal)
        location.setTitle(NSLocalizedString("Add Location", comment: ""), forState: .Normal)
        descr.setTitle(NSLocalizedString("Add Description", comment: ""), forState: .Normal)

        name.text = nil
        limitInt = 0
        updateLimitButtonsUI()
    }

    func madeDateTimeChoice(date: NSDate){
        
        chosenDate = date
        
        let dateString = dateFormatter.stringFromDate(chosenDate!)
        dateTimeButton.setTitle(dateString, forState: UIControlState.Normal)
    }
    
    func madeLocationChoice(coordinates: CLLocationCoordinate2D){
        latitude = coordinates.latitude
        longitude = coordinates.longitude
        CLLocation(latitude: latitude!, longitude: longitude!).getLocationString(nil, button: location, timezoneCompletion: {
            result in
            self.timeZone = result
        })
    }
    
    
    func madeCategoryChoice(categories: [Category]) {
        chosenCategories = categories
        if(chosenCategories.count > 0){
            var names:[String] = []
            for (_, category) in (chosenCategories?.enumerate())! {
                names.append(category.name)
            }
            
           self.pickCategory.setTitle(names.joinWithSeparator(", "), forState: .Normal)
            
        } else {
            pickCategory.setTitle("Share with Group", forState: .Normal)
        }
    }
    
    func madeEventPictureChoice(photo: File, pickedPhoto: UIImage?) {
        chosenPhoto = photo

        eventImage.contentMode = .ScaleAspectFill

        if pickedPhoto != nil {
            eventImage.image = pickedPhoto!
        } else if let photoURLString = photo.url,
            photoURL = NSURL(string: photoURLString) {
            eventImage.sd_setImageWithURL(photoURL, completed: { (_, error, _, _) in
                if error != nil {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
   
    @IBAction func changeLimit(sender: AnyObject) {
        limitInt = sender.tag

        updateLimitButtonsUI()
    }

    func updateLimitButtonsUI() {
        for(_, attendeeButton) in attendeesButtons.enumerate(){
            var buttonImage:UIImage
            if(limitInt < attendeeButton.tag){
                buttonImage = UIImage(named: "accept")!
            } else {
                buttonImage = UIImage(named: "searchingicon")!
            }
            attendeeButton.setImage(buttonImage, forState: .Normal)
        }
    }
    
    @IBAction func addLocationButtonPressed(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier(ChooseLocationViewController.storyboardID) as? ChooseLocationViewController else {
            return
        }

        vc.delegate = self

        presentViewController(vc, animated: true, completion: nil)
    }

    @IBAction func openAboutMeEditor(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("WriteAboutViewController") as? WriteAboutViewController else {
            return
        }

        vc.delegate = self
        vc.textAbout = descriptionText
        vc.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func writeAboutDone(text: String) {
        self.descriptionText = text
        self.descr.setTitle(text.isEmpty ? NSLocalizedString("Add Description", comment: "") : text, forState: .Normal)
    }

    @IBAction func create(sender: AnyObject) {
        guard let currentUserID = ParseHelper.sharedInstance.currentUser?.objectId else {
            return
        }

        if name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter name")
        } else if longitude == nil || latitude == nil {
            MessageToUser.showDefaultErrorMessage("Please choose location")
        } else if chosenDate == nil {
            MessageToUser.showDefaultErrorMessage("Please choose date")
        } else if descriptionText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter description")
        } else if chosenCategories.count == 0 {
            MessageToUser.showDefaultErrorMessage("OOPS, Please Share event with a Group")
        } else if chosenPhoto == nil {
            MessageToUser.showDefaultErrorMessage("Please choose photo")
        } else {
            spinner.startAnimating()
            createButton.enabled = false
            
            if event == nil {
                let eventACL = ObjectACL()
                eventACL.publicWriteAccess = true
                eventACL.publicReadAccess = true
                
                self.event = Event()
                self.event!.ACL = eventACL
                self.event!.attendeeIDs = []
            }
            self.event!.name = name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.event!.summary = descriptionText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.event!.categories = chosenCategories // Unable to save a PFObject with a relation to a cycle.
            self.event!.startDate = chosenDate!
            self.event!.photo = chosenPhoto!
            self.event!.limit = (limitInt+1)
            self.event!.owner = ParseHelper.sharedInstance.currentUser!
            self.event!.location = GeoPoint(latitude: latitude!, longitude: longitude!)
            self.event!.timeZone = timeZone!.name

            ParseHelper.saveObject(self.event!, completion: {
                (result, error) in
                if error == nil {
                    if (self.event?.attendeeIDs.contains(currentUserID) != true) {
                        self.event?.attendeeIDs.append(currentUserID)
                    }

                    ParseHelper.saveObject(self.event!, completion: { (result, error) in
                        if (self.isEditMode) {
                            self.delegate?.eventChanged(self.event!)
                            self.navigationController?.popViewControllerAnimated(true)
                        }

                        self.spinner.stopAnimating()

                        if !self.isEditMode {
                            if DataProxy.sharedInstance.needsShowInviteHint {
                                if let shareEventHintVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ShareEventHintViewController.storyboardID) as? ShareEventHintViewController {
                                    shareEventHintVC.event = self.event
                                    shareEventHintVC.onCancelPressed = { [weak self] in
                                        self?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                                        self?.tabBarController?.selectedIndex = 0
                                        self?.resetContent()
                                    }

                                    DataProxy.sharedInstance.needsShowInviteHint = false
                                    self.presentViewController(shareEventHintVC, animated: true, completion: nil)
                                }
                            } else {
                                guard let shareItemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ShareItemViewController.storyboardID) as? ShareItemViewController else {
                                    return
                                }

                                shareItemVC.modalPresentationStyle = .OverCurrentContext
                                shareItemVC.modalTransitionStyle = .CrossDissolve
                                shareItemVC.item = self.event
                                shareItemVC.onCancelPressed = { [weak self] in
                                    self?.presentedViewController?.dismissViewControllerAnimated(false, completion: nil)
                                    self?.tabBarController?.selectedIndex = 0
                                    self?.resetContent()
                                }

                                self.presentViewController(shareItemVC, animated: true, completion: nil)
                            }
                        }
                    })
                } else {
                    self.spinner.stopAnimating()
                    self.createButton.enabled = false
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "category") {
            
            let vc = (segue.destinationViewController as! CategoryPickerViewController)
                vc.categoryDelegate = self
                vc.selectedCategoriesData = chosenCategories
        }
    }

    //MARK: - Notification Handlers
    func handleUserLogout() {
        navigationController?.popToRootViewControllerAnimated(false)
        resetContent()
    }
}
