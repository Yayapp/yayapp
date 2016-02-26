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

class InstagramViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var delegate:InstagramDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        
        let requestURL = InstagramEngine.sharedEngine().authorizationURLForScope(InstagramKitLoginScope.Relationships)
        
//        NSURL(string:"https://instagram.com/oauth/authorize/?client_id=aec497e4d81e4b758aa48a94b3c35c00&redirect_uri=http://www.textquickit.com&response_type=token&scope=relationships")
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
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
        
//        var error:NSErrorPointer = NSErrorPointer()
//        if (InstagramEngine.sharedEngine().extractValidAccessTokenFromURL(request.URL, error: error)) {
//            if (error != nil) {
//                
//            } else {
//                
//            }
//        }
        return true
        
//        
//        
//        let urlString:String! = request.URL!.absoluteString
//        
//        if let range:Range<String.Index> = urlString.rangeOfString("access_token=") {
//            delegate!.instagramSuccess(urlString.substringFromIndex(range.endIndex))
//            dismissViewControllerAnimated(true, completion: nil)
//            return false
//        }
//        
//        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        MessageToUser.showDefaultErrorMessage(error?.localizedDescription)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

