//
//  EventDetailsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    var event:Event!
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation!
    
    @IBOutlet weak var photo: PFImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var descr: UITextView!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        if let user = PFUser.currentUser() {
            let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
            currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
        } else {
            currentLocation = CLLocation(latitude: TempUser.location!.latitude, longitude: TempUser.location!.longitude)
        }
        
        var distanceBetween: CLLocationDistance = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude).distanceFromLocation(currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        title  = event.name
        name.text = event.name
        descr.text = event.summary
        photo.file = event.photo
        photo.loadInBackground()
        date.text = dateFormatter.stringFromDate(event.startDate)
        
        distance.text = "\(distanceStr)km"
        getLocationString(event.location.latitude, longitude: event.location.longitude)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func getLocationString(latitude: Double, longitude: Double){
        let geoCoder = CLGeocoder()
        let cllocation = CLLocation(latitude: latitude, longitude: longitude)
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
                self.location.text = cityCountry as String
            }
        })
        
    }
}
