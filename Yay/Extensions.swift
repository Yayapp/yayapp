//
//  Extensions.swift
//  Yay
//
//  Created by Nerses Zakoyan on 30.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//
import UIKit

extension String {
    func MD5() -> String {
        let data = (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))
        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result!.mutableBytes)
        CC_MD5(data!.bytes, CC_LONG(data!.length), resultBytes)
        
        let buff = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result!.length)
        let hash = NSMutableString()
        for i in buff {
            hash.appendFormat("%02x", i)
        }
        return hash as String
    }
}

extension Array {
    func combine(separator: String) -> String{
        var str : String = ""
        for (idx, item) in self.enumerate() {
            str += "\(item)"
            if idx < self.count-1 {
                str += separator
            }
        }
        return str
    }
}

extension String {
    func isEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$",
            options: [.CaseInsensitive])

        return regex.firstMatchInString(self, options:[],
            range: NSMakeRange(0, utf16.count)) != nil
    }
}

extension User {
    func getName() -> String {
        return name!
    }

    func getImage(completion: (result: UIImage?) -> Void) {
        guard let file = self.avatar else {
            completion(result: nil)

            return
        }

        ParseHelper.getData(file, completion: {
            result, error in
            var image:UIImage!
            if error == nil {
               image = UIImage(data: result!)
            } else {
               image = UIImage(named: "upload_pic")
            }
            completion(result: image)
        })
    }
}

extension CLLocation {
    func getLocationString(label:UILabel?, button:UIButton?, timezoneCompletion:((NSTimeZone) -> ())?){
    let geoCoder = CLGeocoder()
    let cityCountry:NSMutableString=NSMutableString()
    geoCoder.reverseGeocodeLocation(self, completionHandler: { (placemarks, error) -> Void in
        
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
            if label != nil {
                label!.text = cityCountry as String
            } else {
                button!.setTitle(cityCountry as String, forState: .Normal)
            }
            
        }
        }
    })
    }
    
    func setLocationString(label:UITextView, button:UIButton, timezoneCompletion:((NSTimeZone) -> ())?){
        let geoCoder = CLGeocoder()
        let cityCountry:NSMutableString=NSMutableString()
        geoCoder.reverseGeocodeLocation(self, completionHandler: { (placemarks, error) -> Void in
            
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

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * -2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.addAnimation(rotateAnimation, forKey: nil)
    }
}

extension UIImage {
func resizeToDefault() -> UIImage {
    let size = self.size
    
    if self.size.width>800 && self.size.height>600 {
    let widthRatio  = 800  / self.size.width
    let heightRatio = 600 / self.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
        newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
    } else {
        return self
    }
}
}
extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: self.borderColor!)
        }
    }
}
