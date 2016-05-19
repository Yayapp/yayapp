//
//  BlurryAlertViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 13.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit
import Darwin

final class BlurryAlertViewController: UIViewController {
    
    static let BUTTON_OK = "okbutton"
    static let BUTTON_DELETE = "deletebutton"
    
    @IBOutlet private weak var cancel: UIButton?
    @IBOutlet private weak var cancelButtonPlaceholderView: UIView?
    @IBOutlet private weak var about: UILabel?
    @IBOutlet private weak var message: UILabel?
    @IBOutlet private weak var centerButton: UIButton?
    
    private var event: Event?
    
    var aboutText: String! = ""
    var messageText: String! = ""
    var action: String?
    var completion:(()->Void)?
    var onUserLoggedOut:((error :NSError?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButtonPlaceholderView?.layer.cornerRadius = cancelButtonPlaceholderView?.bounds.width ?? 0 / 2
        
        about?.text = aboutText
        message?.text = messageText
        
        if let action = action {
            centerButton?.setImage(UIImage(named: action), forState: .Normal)
            centerButton?.addTarget(self, action: Selector(action), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        self.view.insertSubview(blurEffectView, atIndex: 0)
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
    @IBAction func okbutton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:completion)
    }
    
    @IBAction func deletebutton() {
        if event != nil {
            ParseHelper.deleteObject(event, completion: {
                result, error in
                if error == nil {
                    if result == true {
                        self.dismissViewControllerAnimated(true, completion:self.completion!)
                    } else {
                        MessageToUser.showDefaultErrorMessage("Couldn't remove the event")
                    }
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        } else if let currentUser = ParseHelper.sharedInstance.currentUser {
            SVProgressHUD.show()
            ParseHelper.removeUserEvents(currentUser, block: {
                result, error in
                if error == nil {
                    ParseHelper.deleteObject(currentUser, completion: { [weak self] (_, error) in
                        SVProgressHUD.dismiss()
                        self?.dismissViewControllerAnimated(true, completion: {
                            self?.onUserLoggedOut?(error: error)
                        })
                        })
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
    }
}
