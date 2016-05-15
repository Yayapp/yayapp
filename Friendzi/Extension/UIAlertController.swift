//
//  UIAlertController.swift
//  Friendzi
//
//  Created by Erison on 5/11/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit
/**
 Show an alret controller with the given text and title
 */
extension UIAlertController {
    class func showSimpleAlertViewWithText(text: String,
                                           title: String,
                                           controller: UIViewController, completion: (() -> Void)?,
                                           alertHandler: (UIAlertAction -> Void)?) {

        let alert = UIAlertController(title: title, message: text, preferredStyle: .Alert)
        let closeAction = UIAlertAction(title: "Close".localized, style: .Cancel, handler: alertHandler)
        alert.addAction(closeAction)
        controller.presentViewController(alert, animated: true, completion: completion)
    }
}