//
//  TermsController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 28.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class TermsController: UIViewController {
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var text: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        
            let attrString = try? NSMutableAttributedString(
            data: text.text.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil)
        
        text.attributedText = attrString
    }
   
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            self.appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        })
    }
}
