//
//  InstagramViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 22.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

protocol InstagramDelegate : NSObjectProtocol {
    func instagramSuccess(token:String, user:InstagramUser)
    func instagramFailure()
}

final class InstagramViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet private weak var webView: UIWebView?

    weak var delegate:InstagramDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView?.delegate = self
        let requestURL = InstagramEngine.sharedEngine().authorizationURLForScope(InstagramKitLoginScope.Relationships)
        let request = NSURLRequest(URL: requestURL)
        webView?.loadRequest(request)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
                let urlString:String! = request.URL!.absoluteString
        
                if let range:Range<String.Index> = urlString.rangeOfString("access_token=") {
										let token = urlString.substringFromIndex(range.endIndex)
                    let engine = InstagramEngine.sharedEngine()
										engine.accessToken = token
                    engine.getSelfUserDetailsWithSuccess({
                        (user:InstagramUser?) in

											self.dismissViewControllerAnimated(true, completion: { () -> Void in
												self.delegate!.instagramSuccess(token, user: user!)
											})
                        },
                        failure: {
                            (error:NSError?, statusCode:Int) in
                            print(error, terminator: "")
                    })
                    
                    return false
                }

        return true
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

