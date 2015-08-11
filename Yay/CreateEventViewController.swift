//
//  CreateEventViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 16.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class CreateEventViewController: UIViewController, ChooseDateDelegate, ChooseLocationDelegate, ChooseCategoryDelegate, ChooseEventPictureDelegate, UIPopoverPresentationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, TTRangeSliderDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let dateFormatter = NSDateFormatter()
    var minAge:Int! = 16
    var maxAge:Int! = 99
    var longitude: Double?
    var latitude: Double?
    var chosenDate:NSDate?
    var chosenCategory:Category?
    var chosenPhoto:PFFile?
    
    var animateDistance:CGFloat = 0.0
    var limitInt:Int=1
    
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
    @IBOutlet weak var descr: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        descr.delegate = self
        name.delegate = self
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        rangeSlider.delegate = self
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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

        
        var detailPopover: UIPopoverPresentationController = map.popoverPresentationController!
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
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func openCategoryPicker(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseCategoryViewController") as! ChooseCategoryViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func madeDateTimeChoice(date: NSDate){
        chosenDate = date
        
        let dateString = dateFormatter.stringFromDate(date)
        dateTimeButton.setTitle(dateString, forState: UIControlState.Normal)
    }
    
    func madeLocationChoice(coordinates: CLLocationCoordinate2D){
        latitude = coordinates.latitude
        longitude = coordinates.longitude
        getLocationString(coordinates)
    }
    
    
    func madeCategoryChoice(category: Category) {
        chosenCategory = category
        pickCategory.setTitle(category.name, forState: .Normal)
    }
    
    func madeEventPictureChoice(photo: PFFile, pickedPhoto: UIImage?) {
        chosenPhoto = photo
        if pickedPhoto != nil {
            eventPhoto.setImage(pickedPhoto, forState: .Normal)
        } else {
            photo.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil) {
                    var image = UIImage(data:data!)
                    self.eventPhoto.setImage(image, forState: .Normal)
                }
            })
        }
    }

    func getLocationString(coordinates: CLLocationCoordinate2D){
        let geoCoder = CLGeocoder()
        let cllocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        var cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(cllocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as? [CLPlacemark]
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // City
            if let city = placeMark.addressDictionary["City"] as? String {
                cityCountry.appendString(city)
            }
            // Country
            if let country = placeMark.addressDictionary["Country"] as? String {
                if cityCountry.length>0 {
                    cityCountry.appendString(", ")
                }
                cityCountry.appendString(country)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
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
    
    func textViewDidBeginEditing(textField: UITextView) {
        textDidBeginEditing(textField)
    }
    
    func textViewdDidEndEditing(textField: UITextView) {
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
    func textViewShouldReturn(textField: UITextView) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
           
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func plusLimit(sender: AnyObject) {
        limit.textColor = UIColor.whiteColor()
        if limitInt < 5 {
            limitInt++
            limit.text = "\(limitInt)"
        }
    }
    @IBAction func minusLimit(sender: AnyObject) {
        limit.textColor = UIColor.whiteColor()
        if limitInt > 1 {
            limitInt--
            limit.text = "\(limitInt)"
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func create(sender: AnyObject) {
        
        if name.text.isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter name")
        } else if longitude == nil || latitude == nil {
            MessageToUser.showDefaultErrorMessage("Please choose location")
        } else if chosenDate == nil {
            MessageToUser.showDefaultErrorMessage("Please choose date")
        } else if descr.text.isEmpty {
            MessageToUser.showDefaultErrorMessage("Please enter description")
        } else if chosenCategory == nil {
            MessageToUser.showDefaultErrorMessage("Please choose category")
        } else if chosenPhoto == nil {
            MessageToUser.showDefaultErrorMessage("Please choose photo")
        } else {
            spinner.startAnimating()
            var event = Event()
            event.name = name.text
            event.summary = descr.text
            event.category = chosenCategory!
            event.startDate = chosenDate!
            event.photo = chosenPhoto!
            event.limit = limitInt
            event.minAge = minAge
            event.maxAge = maxAge
            event.owner = PFUser.currentUser()!
            event.location = PFGeoPoint(latitude: latitude!, longitude: longitude!)
            event.attendees = []
            event.saveInBackgroundWithBlock({
                (result, error) in
                if error == nil {
                    event.addObject(PFUser.currentUser()!, forKey: "attendees")
                    event.saveInBackgroundWithBlock({
                        (result, error) in
                        self.spinner.stopAnimating()
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            })
        }
    }
    deinit {
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
    }
}
