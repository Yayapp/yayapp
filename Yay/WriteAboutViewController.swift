//
//  WriteAboutViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 17.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class WriteAboutViewController: UIViewController {
    
    @IBOutlet weak var text: UITextView!
    
    var textAbout:String!

    var delegate: WriteAboutDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        text.text = textAbout
        text.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ok(sender: AnyObject) {
        delegate.writeAboutDone(text.text)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
protocol WriteAboutDelegate : NSObjectProtocol {
    func writeAboutDone(text: String)
}