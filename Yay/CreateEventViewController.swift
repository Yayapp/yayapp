//
//  CreateEventViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

protocol EventCreationDelegate : NSObjectProtocol {
    func eventCreated(event:Event)
}

class CreateEventViewController: KeyboardAnimationHelper, ChooseDateDelegate, ChooseLocationDelegate, CategoryPickerDelegate, ChooseEventPictureDelegate, WriteAboutDelegate, UIPopoverPresentationControllerDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)

    var event:Event?
    
    let dateFormatter = NSDateFormatter()
    var longitude: Double?
    var latitude: Double?
    var chosenDate:NSDate?
    var chosenCategories:[Category]! = []
    var chosenPhoto: File?
    var delegate:EventCreationDelegate!
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attendeesButtons = [attendee1, attendee2, attendee3, attendee4]
        
        pickCategory.layer.borderColor = UIColor.whiteColor().CGColor
        name.delegate = self
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        if event != nil {
            update()
            title = "Edit Event"
        } else {
            title = "Create Event"
        }

        if let avatar = ParseHelper.sharedInstance.currentUser?.avatar {
            ParseHelper.getData(avatar, completion: {
                (data:NSData?, error:NSError?) in
                if(error == nil) {
                    let image = UIImage(data:data!)
                    self.author.setImage(image, forState: .Normal)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
    }
  
    
    func update() {
        ParseHelper.fetchObject(event!, completion: {
            result, error in
            if error == nil {
                self.title  = self.event!.name
                self.name.text = self.event!.name
                self.descriptionText = self.event!.summary
                self.descr.setTitle(self.event!.summary, forState: .Normal)
                self.limitInt = self.event!.limit-1
                let dummyButton:UIButton = UIButton()
                dummyButton.tag = self.limitInt - 1
                self.changeLimit(dummyButton)
                self.madeCategoryChoice(self.event!.categories)
                self.madeEventPictureChoice(self.event!.photo, pickedPhoto: nil)
                self.madeDateTimeChoice(self.event!.startDate)
                self.madeLocationChoice(CLLocationCoordinate2D(latitude: self.event!.location.latitude, longitude: self.event!.location.longitude))
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
    }
    
    @IBAction func openDateTimePicker(sender: AnyObject) {
        guard let map = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ChooseDateTimeViewController") as? ChooseDateTimeViewController else {
            return
        }

        map.delegate = self
        map.modalPresentationStyle = UIModalPresentationStyle.Popover

        
        let detailPopover: UIPopoverPresentationController = map.popoverPresentationController!
        detailPopover.delegate = self
        detailPopover.sourceView = sender as! UIButton
        
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Down
        presentViewController(map,
            animated: true, completion:nil)
        
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
            pickCategory.setTitle("PICK CATEGORY", forState: .Normal)
        }
    }
    
    func madeEventPictureChoice(photo: File, pickedPhoto: UIImage?) {
        chosenPhoto = photo
        if pickedPhoto != nil {
            eventImage.image = pickedPhoto!
            eventImage.contentMode = UIViewContentMode.ScaleAspectFill
        } else {
            ParseHelper.getData(photo, completion: {
                    (data:NSData?, error:NSError?) in
                    if(error == nil) {
                        let image = UIImage(data:data!)
                        self.eventImage.image = image
                        self.eventImage.contentMode = UIViewContentMode.ScaleAspectFill
                    } else {
                        MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                    }
                })
            
        }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
   
    @IBAction func changeLimit(sender: AnyObject) {
        limitInt = sender.tag + 1
        for(index, attendeeButton) in attendeesButtons.enumerate(){
            var buttonImage:UIImage
            if(index>sender.tag){
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
        self.descr.setTitle(text, forState: .Normal)
    }

   

    @IBAction func create(sender: AnyObject) {
        
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
                self.event!.attendees = []
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
                    self.event!.attendees.append(ParseHelper.sharedInstance.currentUser!)
                    ParseHelper.saveObject(self.event!, completion: {
                        (result, error) in
                                                
                        let root = self.tabBarController?.viewControllers![2] as! UINavigationController
                        root.popViewControllerAnimated(false)
                        guard let vc = UIStoryboard.createEventTab()?.instantiateViewControllerWithIdentifier("CreateEventViewController") as? CreateEventViewController else {
                            return
                        }

                        root.pushViewController(vc, animated: false)
                        self.spinner.stopAnimating()
                        self.tabBarController?.selectedIndex = 0
                        
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
}
