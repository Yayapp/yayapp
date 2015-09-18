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
    
    var isRotating = false
    var shouldStopRotating = false
    
    @IBOutlet weak var searchingAnimation: UIImageView!
    @IBOutlet weak var location: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isRotating == false {
            self.searchingAnimation.rotate360Degrees(completionDelegate: self)
            self.isRotating = true
        }
        
        PFGeoPoint.geoPointForCurrentLocationInBackground( {
            (geoPoint:PFGeoPoint?, error:NSError?) in
            if (error == nil) {
                if PFUser.currentUser() != nil {
                   PFUser.currentUser()!.setObject(geoPoint!, forKey:"location")
                    PFUser.currentUser()!.saveInBackground()
                } else {
                    TempUser.location = CLLocationCoordinate2D(latitude: geoPoint!.latitude, longitude: geoPoint!.longitude)
                }
                self.shouldStopRotating = true
                self.goToMain()
            } else {
                MessageToUser.showDefaultErrorMessage("Can't retreive location automatically. Please choose location manually")
                self.shouldStopRotating = true
            }
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if (Prefs.getPref(Prefs.Welcome) == false) {
            let tutorialViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
            tutorialViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            tutorialViewController.hints = [Prefs.Welcome]
            self.presentViewController(tutorialViewController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.shouldStopRotating == false {
            self.searchingAnimation.rotate360Degrees(completionDelegate: self)
        } else {
            self.reset()
        }
    }
    
    func reset() {
        self.isRotating = false
        self.shouldStopRotating = false
    }

    func goToMain() {
        if((PFUser.currentUser()) != nil) {
            appDelegate.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
                self.appDelegate.window!.rootViewController = self.appDelegate.centerContainer
                self.appDelegate.window!.makeKeyAndVisible()
 
        } else {
            let main = self.storyboard!.instantiateViewControllerWithIdentifier("MainNavigationController") as! MainNavigationController
            presentViewController(main, animated: true, completion: nil)
        }
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
        
        if let user = PFUser.currentUser() {
            user.setObject(PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude), forKey: "location")
            user.save()
        } else {
            TempUser.location = coordinates
        }
        goToMain()
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
    
}

