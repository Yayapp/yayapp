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

class CreateEventViewController: KeyboardAnimationHelper, ChooseDateDelegate, ChooseLocationDelegate, ChooseCategoryDelegate, ChooseEventPictureDelegate, UIPopoverPresentationControllerDelegate, TTRangeSliderDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    var event:Event?
    
    let dateFormatter = NSDateFormatter()
    var minAge:Int! = 16
    var maxAge:Int! = 99
    var longitude: Double?
    var latitude: Double?
    var chosenDate:NSDate?
    var chosenCategory:Category?
    var chosenPhoto:PFFile?
    var delegate:EventCreationDelegate!
    var timeZone:NSTimeZone!
    
    var limitInt:Int=1
    
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var pickCategory: UIButton!
    @IBOutlet var eventPhoto: UIButton!
    @IBOutlet var limit: UITextField!
    @IBOutlet var dateTimeButton: UIButton!
    @IBOutlet var location: UIButton!
    
    @IBOutlet var rangeSlider: TTRangeSlider!
    @IBOutlet var rangeLabel: UILabel!
    @IBOutlet var sliderContainer: UIView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet var name: UITextField!
    @IBOutlet var descr: UITextField!

    @IBOutlet var createButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        pickCategory.layer.borderColor = UIColor.whiteColor().CGColor
        descr.delegate = self
        name.delegate = self
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        rangeSlider.delegate = self
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        
        if event != nil {
            update()
            title = "Edit Event"
        } else {
            title = "Create Event"
        }
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
    }
  
    
    func update() {
        event!.fetchInBackgroundWithBlock({
            result, error in
            if error == nil {
                self.title  = self.event!.name
                self.name.text = self.event!.name
                self.descr.text = self.event!.summary
                self.limitInt = self.event!.limit-1
                self.limit.text = "\(self.limitInt)"
                self.rangeSlider.selectedMinimum = Float(self.event!.minAge)
                self.rangeSlider.selectedMaximum = Float(self.event!.maxAge)
                self.rangeLabel.text = "\(Int(self.rangeSlider.selectedMinimum))-\(Int(self.rangeSlider.selectedMaximum))"
                self.madeCategoryChoice([self.event!.category])
                self.madeEventPictureChoice(self.event!.photo, pickedPhoto: nil)
                self.madeDateTimeChoice(self.event!.startDate)
                self.madeLocationChoice(CLLocationCoordinate2D(latitude: self.event!.location.latitude, longitude: self.event!.location.longitude))
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        
    }
    
    func rangeSlider(sender:TTRangeSlider, didChangeSelectedMinimumValue selectedMinimum:Float, andMaximumValue selectedMaximum:Float){
        minAge = Int(selectedMinimum)
        maxAge = Int(selectedMaximum)
        rangeLabel.text = "\(Int(selectedMinimum))-\(Int(selectedMaximum))"
    }
  
    
    @IBAction func openDateTimePicker(sender: AnyObject) {
        let map = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseDateTimeViewController") as! ChooseDateTimeViewController
        map.delegate = self
        map.modalPresentationStyle = UIModalPresentationStyle.Popover

        
        let detailPopover: UIPopoverPresentationController = map.popoverPresentationController!
        detailPopover.delegate = self
        detailPopover.sourceView = sender as! UIButton
        
        detailPopover.permittedArrowDirections = UIPopoverArrowDirection.Down
        presentViewController(map,
            animated: true, completion:nil)
        
    }
    
    @IBAction func openLocationPicker(sender: AnyObject) {
        let map = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseLocationViewController") as! ChooseLocationViewController
        map.delegate = self
        map.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        map.setEditing (true,animated: true)
        presentViewController(map, animated: true, completion: nil)
    }
    
    @IBAction func openPhotoPicker(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseEventPictureViewController") as! ChooseEventPictureViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openCategoryPicker(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseCategoryViewController") as! ChooseCategoryViewController
        vc.delegate = self
        vc.isEventCreation = true
        if chosenCategory != nil {
            vc.selectedCategoriesData = [chosenCategory!]
        }
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
        chosenCategory = categories.first
        if(chosenCategory != nil){
            chosenCategory?.fetchInBackgroundWithBlock({
                result, error in
                if error == nil {
                    self.pickCategory.setTitle(self.chosenCategory!.name, forState: .Normal)
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else {
            pickCategory.setTitle("PICK CATEGORY", forState: .Normal)
        }
    }
    
    func madeEventPictureChoice(photo: PFFile, pickedPhoto: UIImage?) {
        chosenPhoto = photo
        if pickedPhoto != nil {
            eventImage.image = pickedPhoto!
            eventImage.contentMode = UIViewContentMode.ScaleAspectFill
        } else {
            if photo.isDataAvailable {
                do {
                    self.eventImage.image = UIImage(data:try photo.getData())
                    self.eventImage.contentMode = UIViewContentMode.ScaleAspectFill
                } catch {
                    //
                }
            } else {
                photo.getDataInBackgroundWithBlock({
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
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
   
    @IBAction func plusLimit(sender: AnyObject) {
        if limitInt < 4 {
            limitInt++
            limit.text = "\(limitInt)"
        }
    }
    @IBAction func minusLimit(sender: AnyObject) {
        if limitInt > 1 {
            limitInt--
            limit.text = "\(limitInt)"
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func create(sender: AnyObject) {
        
        if name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter name")
        } else if longitude == nil || latitude == nil {
            MessageToUser.showDefaultErrorMessage("Please choose location")
        } else if chosenDate == nil {
            MessageToUser.showDefaultErrorMessage("Please choose date")
        } else if descr.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter description")
        } else if chosenCategory == nil {
            MessageToUser.showDefaultErrorMessage("Please choose category")
        } else if chosenPhoto == nil {
            MessageToUser.showDefaultErrorMessage("Please choose photo")
        } else {
            spinner.startAnimating()
            createButton.enabled = false
            cancelButton.enabled = false
            
            if event == nil {
                let eventACL:PFACL = PFACL()
                eventACL.setPublicWriteAccess(true)
                eventACL.setPublicReadAccess(true)
                
                self.event = Event()
                self.event!.ACL = eventACL
                self.event!.attendees = []
            }
            self.event!.name = name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.event!.summary = descr.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.event!.category = chosenCategory!
            self.event!.startDate = chosenDate!
            self.event!.photo = chosenPhoto!
            self.event!.limit = (limitInt+1)
            self.event!.minAge = minAge
            self.event!.maxAge = maxAge
            self.event!.owner = PFUser.currentUser()!
            self.event!.location = PFGeoPoint(latitude: latitude!, longitude: longitude!)
            self.event!.timeZone = timeZone!.name
            
            self.event!.saveInBackgroundWithBlock({
                (result, error) in
                if error == nil {
                    self.event!.addObject(PFUser.currentUser()!, forKey: "attendees")
                    self.event!.saveInBackgroundWithBlock({
                        (result, error) in
                        
                        if ((PFUser.currentUser()?.objectForKey("eventsReminder") as! Bool)) {
                            let components = NSDateComponents()
                            
                            components.hour = -1
                            let hourBefore = self.calendar!.dateByAddingComponents(components, toDate: self.event!.startDate, options: [])
                            components.hour = -24
                            let hour24Before = self.calendar!.dateByAddingComponents(components, toDate: self.event!.startDate, options: [])
                            
                            
                            let localNotification1:UILocalNotification = UILocalNotification()
                            localNotification1.alertAction = "\(self.event!.name)"
                            localNotification1.alertBody = "Don't forget to participate on happening \"\(self.event!.name)\" on \(self.dateFormatter.stringFromDate(self.event!.startDate))"
                            localNotification1.fireDate = hourBefore
                            UIApplication.sharedApplication().scheduleLocalNotification(localNotification1)
                            
                            let localNotification24:UILocalNotification = UILocalNotification()
                            localNotification24.alertAction = "\(self.event!.name)"
                            localNotification24.alertBody = "Don't forget to participate on happening \"\(self.event!.name)\" on \(self.dateFormatter.stringFromDate(self.event!.startDate))"
                            localNotification24.fireDate = hour24Before
                            UIApplication.sharedApplication().scheduleLocalNotification(localNotification24)
                        }
                        
                        self.spinner.stopAnimating()
                        self.delegate.eventCreated(self.event!)
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                } else {
                    self.spinner.stopAnimating()
                    self.createButton.enabled = false
                    self.cancelButton.enabled = false
                }
            })
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
   
    
    deinit {
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
    }
}
