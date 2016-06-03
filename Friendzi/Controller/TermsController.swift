//
//  TermsController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 28.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class TermsController: UIViewController {

    @IBOutlet private weak var webView: UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = NSBundle.mainBundle().URLForResource("termsOfService", withExtension: "html") {
            webView?.loadRequest(NSURLRequest(URL: path))
        }
    }

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
        })
    }
}