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
        
            var attrString = NSMutableAttributedString(
            data: text.text.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!,
            options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
            documentAttributes: nil,
            error: nil)
        
        text.attributedText = attrString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
        })
    }
}
