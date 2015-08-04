//
//  UserProfileViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 18.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class UserProfileViewController: UITableViewController {

    var user:PFUser!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var avatar: PFImageView!
    @IBOutlet weak var eventsCount: UILabel!
    @IBOutlet weak var interests: UILabel!
    @IBOutlet weak var about: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = user.objectForKey("name") as? String
        
        let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
        getLocationString(currentPFLocation.latitude, longitude: currentPFLocation.longitude)
        
        let avatarfile = user.objectForKey("avatar") as? PFFile
        if(avatarfile != nil) {
            avatar.file = avatarfile
            avatar.loadInBackground()
        }
        if user["about"] != nil {
            let font17 = UIFont.systemFontOfSize(17)
            let font12 = UIFont.systemFontOfSize(12)
            let myMutableString = NSMutableAttributedString(string: about.text!+(user["about"] as! String), attributes: [NSFontAttributeName:font17])
            myMutableString.addAttribute(NSFontAttributeName, value: font12, range: NSRange(location: count(about.text!), length: count((user["about"]! as! String))))
            
            about.attributedText = myMutableString
        }
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
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        
    }
    
    
}
