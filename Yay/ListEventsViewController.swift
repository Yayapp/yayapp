//
//  ListEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ListEventsViewController: EventsViewController, UITableViewDataSource, UITableViewDelegate {

    var requests:Bool = false
    var eventsFirst:[Event]?
    var currentTitle:String?
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation?
    var delegate:ListEventsDelegate?
    
    @IBOutlet weak var events: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        if currentTitle != nil {
            title = currentTitle!
        }
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        if let user = PFUser.currentUser() {
            let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
            currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
        } else {
            currentLocation = CLLocation(latitude: TempUser.location!.latitude, longitude: TempUser.location!.longitude)
        }
        
        events.delegate = self
        events.dataSource = self
        
        if (eventsFirst != nil) {
            reloadAll(eventsFirst!)
        }
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    override func reloadAll(eventsList:[Event]) {
        eventsData = eventsList
        events.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = events.dequeueReusableCellWithIdentifier("Cell") as! EventsTableViewCell
        let event:Event! = eventsData[indexPath.row]
        let distanceBetween: CLLocationDistance = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude).distanceFromLocation(currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        
        cell.title.text = event.name
        
        getLocationString(cell.location, latitude: event.location.latitude, longitude: event.location.longitude)
        
        cell.date.text = dateFormatter.stringFromDate(event.startDate)
        cell.howFar.text = "\(distanceStr)km"
        
        event.photo.getDataInBackgroundWithBlock({
            (data:NSData?, error:NSError?) in
            if(error == nil) {
                var image = UIImage(data:data!)
                cell.picture.image = self.toCobalt(image!)
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (requests) {
            let requestsTableViewController = self.storyboard!.instantiateViewControllerWithIdentifier("RequestsTableViewController") as! RequestsTableViewController
            ParseHelper.getEventRequests(eventsData[indexPath.row], block: {
                result, error in
                if (error == nil) {
                    requestsTableViewController.requests = result!
                    self.navigationController?.pushViewController(requestsTableViewController, animated: true)
                }
            })
            
        } else {
            if(delegate != nil) {
                delegate!.madeEventChoice(eventsData[indexPath.row])
            } else {
                let eventDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailsViewController") as! EventDetailsViewController
                eventDetailsViewController.event = eventsData[indexPath.row]
                self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
            }
        }
    }
    
    func getLocationString(label:UILabel, latitude: Double, longitude: Double){
        let geoCoder = CLGeocoder()
        let cllocation = CLLocation(latitude: latitude, longitude: longitude)
        var cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(cllocation, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as? [CLPlacemark]
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
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
                label.text = cityCountry as String
            }
        })
        
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func toCobalt(image:UIImage) -> UIImage{
        let inputImage:CIImage = CIImage(CGImage: image.CGImage)
        
        // Make the filter
        let colorMatrixFilter:CIFilter = CIFilter(name: "CIColorMatrix")
        colorMatrixFilter.setDefaults()
        colorMatrixFilter.setValue(inputImage, forKey:kCIInputImageKey)
        colorMatrixFilter.setValue(CIVector(x:1, y:1, z:1, w:0), forKey:"inputRVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:1, z:0, w:0), forKey:"inputGVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:0, z:1, w:0), forKey:"inputBVector")
        colorMatrixFilter.setValue(CIVector(x:0, y:0, z:0, w:1), forKey:"inputAVector")
        
        // Get the output image recipe
        let outputImage:CIImage = colorMatrixFilter.outputImage
        
        // Create the context and instruct CoreImage to draw the output image recipe into a CGImage
        let context:CIContext = CIContext(options:nil)
        let cgimg:CGImageRef = context.createCGImage(outputImage, fromRect:outputImage.extent()) // 10
        
        return UIImage(CGImage:cgimg)!
    }
}
protocol ListEventsDelegate : NSObjectProtocol {
    func madeEventChoice(event: Event)
}
