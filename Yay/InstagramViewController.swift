//
//  InstagramViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 22.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit


class InstagramViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var delegate:InstagramDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        
        
//        InstagramEngine.sharedEngine().appClientID = "aec497e4d81e4b758aa48a94b3c35c00"
//        InstagramEngine.sharedEngine().appRedirectURL = "http://www.textquickit.com"
        
        let requestURL = InstagramEngine.sharedEngine().authorizarionURLForScope(InstagramKitLoginScope.Relationships)
        
//        NSURL(string:"https://instagram.com/oauth/authorize/?client_id=aec497e4d81e4b758aa48a94b3c35c00&redirect_uri=http://www.textquickit.com&response_type=token&scope=relationships")
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
                let urlString:String! = request.URL!.absoluteString
        
                if let range:Range<String.Index> = urlString.rangeOfString("access_token=") {
                    let engine = InstagramEngine.sharedEngine()
                    engine.getSelfUserDetailsWithSuccess({
                        (user:InstagramUser?) in
            
                        self.delegate!.instagramSuccess(urlString.substringFromIndex(range.endIndex), user: user!)
                        self.dismissViewControllerAnimated(true, completion: nil)
                        },
                        failure: {
                            (error:NSError?, statusCode:Int) in
                            print(error)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
protocol InstagramDelegate : NSObjectProtocol {
    func instagramSuccess(token:String, user:InstagramUser)
    func instagramFailure()
}
