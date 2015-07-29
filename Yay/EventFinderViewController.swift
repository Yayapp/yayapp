//
//  EventFinderViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class EventFinderViewController: UIViewController, ChooseLocationDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var location: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goToMain(sender: AnyObject) {
        appDelegate.window!.rootViewController = appDelegate.centerContainer
        appDelegate.window!.makeKeyAndVisible()
    }
    
    @IBAction func openLocationPicker(sender: AnyObject) {
        let map = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseLocationViewController") as! ChooseLocationViewController
        map.delegate = self
        map.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        map.setEditing (true,animated: true)
        presentViewController(map, animated: true, completion: nil)
    }
    
    func madeLocationChoice(coordinates: CLLocationCoordinate2D){
        getLocationString(coordinates)
        let user = PFUser.currentUser()
        user?.setObject(PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude), forKey: "location")
        user?.save()
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
                self.location.text=cityCountry as String
            }
        })
        
    }
}
