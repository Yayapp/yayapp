//
//  WriteAboutViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 17.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

protocol WriteAboutDelegate : NSObjectProtocol {
    func writeAboutDone(text: String)
}

class WriteAboutViewController: UIViewController {
    
    @IBOutlet weak var text: UITextView!
    
    var textAbout:String!

    var delegate: WriteAboutDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        text.text = textAbout
        text.becomeFirstResponder()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        self.view.insertSubview(blurEffectView, atIndex: 0)
    }

    @IBAction func ok(sender: AnyObject) {
        delegate.writeAboutDone(text.text)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
