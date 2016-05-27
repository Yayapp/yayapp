//
//  CLLocationExtension.swift
//  Friendzi
//
//  Created by Er on 5/18/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import Foundation
import APTimeZones

extension CLLocation {
    func getLocationString(label:UILabel?, button:UIButton?, timezoneCompletion:((NSTimeZone) -> ())?){
        let geoCoder = CLGeocoder()
        let cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(self, completionHandler: { (placemarks, error) -> Void in
            label?.text = nil
            
            if error == nil {
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                if timezoneCompletion != nil {
                    if #available(iOS 9.0, *) {
                        timezoneCompletion!(placeMark.timeZone())
                    } else {
                        timezoneCompletion!(APTimeZones.sharedInstance().timeZoneWithLocation(placeMark.location, countryCode:placeMark.ISOcountryCode))
                    }
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
                
                if let subLocality = placeMark.subLocality {
                    cityCountry.appendString("\(cityCountry.length > 0 ? ", " : "")\(subLocality)")
                }
                
                if let locality = placeMark.locality {
                    cityCountry.appendString("\(cityCountry.length > 0 ? ", " : "")\(locality)")
                }
                
                if let administrativeArea = placeMark.administrativeArea {
                    cityCountry.appendString("\(cityCountry.length > 0 ? ", " : "")\(administrativeArea)")
                }
                
                if cityCountry.length > 0 {
                    if label != nil {
                        label!.text = cityCountry as String
                    } else {
                        button!.setTitle(cityCountry as String, forState: .Normal)
                    }
                } else {
                    MessageToUser.showDefaultErrorMessage("It is impossible to recognize the coordinates, please try again.".localized)
                }
            }
        })
    }
    
    func setLocationString(label:UITextView, button:UIButton, timezoneCompletion:((NSTimeZone) -> ())?){
        let geoCoder = CLGeocoder()
        let cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(self, completionHandler: { (placemarks, error) -> Void in
            label.text = nil
            
            if error == nil {
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                if timezoneCompletion != nil {
                    if #available(iOS 9.0, *) {
                        timezoneCompletion!(placeMark.timeZone())
                    } else {
                        timezoneCompletion!(APTimeZones.sharedInstance().timeZoneWithLocation(placeMark.location, countryCode:placeMark.ISOcountryCode))
                    }
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
                    
                    label.text = label.text.stringByReplacingOccurrencesOfString("\n", withString: "\n\(cityCountry as String)\n")
                    
                    button.setTitle(cityCountry as String, forState: .Normal)
                    
                    
                }
            }
        })
    }
}
