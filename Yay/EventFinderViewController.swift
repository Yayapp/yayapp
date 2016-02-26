//
//  EventFinderViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class EventFinderViewController: UIViewController, UIAlertViewDelegate, ChooseLocationDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
   
    
    @IBOutlet weak var searchingAnimation: UIImageView!
    @IBOutlet weak var location: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func goToMain() {
            appDelegate.window!.rootViewController = appDelegate.mainNavigation
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
        CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude).getLocationString(nil, button: location, timezoneCompletion: nil)
        
            PFUser.currentUser()!.setObject(PFGeoPoint(latitude: coordinates.latitude, longitude: coordinates.longitude), forKey: "location")
            PFUser.currentUser()!.saveInBackgroundWithBlock({
                result, error in
                self.goToMain()
            })
        
    }
    
    @IBAction func allowAction(sender: AnyObject) {
        PFGeoPoint.geoPointForCurrentLocationInBackground( {
            (geoPoint:PFGeoPoint?, error:NSError?) in
            if (error == nil) {
                    PFUser.currentUser()!.setObject(geoPoint!, forKey:"location")
                    PFUser.currentUser()!.saveInBackground()
                
                self.goToMain()
            } else {
                MessageToUser.showDefaultErrorMessage("Can't retreive location automatically. Please choose location manually", delegate: self)
            }
        })
    }
    
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        switch buttonIndex {
            
        default:
            openLocationPicker(true)
            
        }
    }
}

