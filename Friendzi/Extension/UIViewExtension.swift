//
//  UIViewExtension.swift
//  Friendzi
//
//  Created by Er on 5/18/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

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

    func roundView() {
        self.layer.cornerRadius = self.bounds.height / 2
    }
}