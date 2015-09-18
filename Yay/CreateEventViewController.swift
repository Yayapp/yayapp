//
//  CreateEventViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: UIViewController, ChooseDateDelegate, ChooseLocationDelegate, ChooseCategoryDelegate, ChooseEventPictureDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, TTRangeSliderDelegate {

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
    var animateDistance:CGFloat = 0.0
    var limitInt:Int=1
    
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var pickCategory: UIButton!
    @IBOutlet weak var eventPhoto: UIButton!
    @IBOutlet weak var limit: UITextField!
    @IBOutlet weak var dateTimeButton: UIButton!
    @IBOutlet weak var location: UIButton!
    
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var sliderContainer: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var descr: UITextField!

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
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
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        getLocationString(coordinates)
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
                self.eventImage.image = UIImage(data:photo.getData()!)
                self.eventImage.contentMode = UIViewContentMode.ScaleAspectFill
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

    func getLocationString(coordinates: CLLocationCoordinate2D){
        let geoCoder = CLGeocoder()
        let cllocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        let cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(cllocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            if #available(iOS 9.0, *) {
                self.timeZone = placeMark.timeZone
            } else {
                self.timeZone = APTimeZones.sharedInstance().timeZoneWithLocation(placeMark.location, countryCode:countryCode)
            }
            
            if let building = placeMark.subThoroughfare {
                cityCountry.appendString(building)
            }
            
            if let address = placeMark.thoroughfare {
                if cityCountry.length>0 {
                    cityCountry.appendString(" ")
                }
                cityCountry.appendString(address)
            }
            
            if let zip = placeMark.postalCode {
                if cityCountry.length>0 {
                    cityCountry.appendString(", ")
                }
                cityCountry.appendString(zip)
            }
            if cityCountry.length>0 {
                self.location.setTitle(cityCountry as String, forState: .Normal)
            }
        })
        
    }
    

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .None
    }
    

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
   
    
    struct MoveKeyboard {
        static let KEYBOARD_ANIMATION_DURATION : CGFloat = 0.3
        static let MINIMUM_SCROLL_FRACTION : CGFloat = 0.2;
        static let MAXIMUM_SCROLL_FRACTION : CGFloat = 0.8;
        static let PORTRAIT_KEYBOARD_HEIGHT : CGFloat = 216;
        static let LANDSCAPE_KEYBOARD_HEIGHT : CGFloat = 162;
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textDidBeginEditing(textField)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textDidEndEditing()
    }
    
    func textDidBeginEditing(textField: UIView) {
        let textFieldRect : CGRect = self.view.window!.convertRect(textField.bounds, fromView: textField)
        let viewRect : CGRect = self.view.window!.convertRect(self.view.bounds, fromView: self.view)
        
        let midline : CGFloat = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator : CGFloat = midline - viewRect.origin.y - MoveKeyboard.MINIMUM_SCROLL_FRACTION * viewRect.size.height
        let denominator : CGFloat = (MoveKeyboard.MAXIMUM_SCROLL_FRACTION - MoveKeyboard.MINIMUM_SCROLL_FRACTION) * viewRect.size.height
        var heightFraction : CGFloat = numerator / denominator
        
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }
        
        let orientation : UIInterfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if (orientation == UIInterfaceOrientation.Portrait || orientation == UIInterfaceOrientation.PortraitUpsideDown) {
            animateDistance = floor(MoveKeyboard.PORTRAIT_KEYBOARD_HEIGHT * heightFraction)
        } else {
            animateDistance = floor(MoveKeyboard.LANDSCAPE_KEYBOARD_HEIGHT * heightFraction)
        }
        
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y -= animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
    }
    
    
    func textDidEndEditing() {
        var viewFrame : CGRect = self.view.frame
        viewFrame.origin.y += animateDistance
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        
        UIView.setAnimationDuration(NSTimeInterval(MoveKeyboard.KEYBOARD_ANIMATION_DURATION))
        
        self.view.frame = viewFrame
        
        UIView.commitAnimations()
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
            self.event!.timeZone = timeZone.name
            
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
protocol EventCreationDelegate : NSObjectProtocol {
    func eventCreated(event:Event)
}