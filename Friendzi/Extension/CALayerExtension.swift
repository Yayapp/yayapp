//
//  Extensions.swift
//  Yay
//
//  Created by Nerses Zakoyan on 30.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

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
