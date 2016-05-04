//
//  ShareItemViewController.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/25/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit
import MessageUI

class ShareItemViewController: UIViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    static let storyboardID = "ShareItemViewController"

    @IBOutlet var contentContainerView: UIView!
    
    var item: Object?
    var generatedShortURL: String?
    var onCancelPressed: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentContainerView.layer.masksToBounds = false
        self.contentContainerView.layer.shadowOffset = CGSizeMake(0, 0)
        self.contentContainerView.layer.shadowRadius = 5
        self.contentContainerView.layer.shadowOpacity = 0.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: - Button Selectors
    @IBAction func emailButtonPressed(sender: AnyObject) {
        if !MFMailComposeViewController.canSendMail() {
            MessageToUser.showDefaultErrorMessage(NSLocalizedString("Can't send mail", comment: ""))

            return
        }

        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self

        if generatedShortURL == nil {
            SVProgressHUD.show()
        }

        generateShortURL { [weak self] (url, error) in
            SVProgressHUD.dismiss()

            guard let url = url where error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                return
            }

            mailVC.setMessageBody(url, isHTML: false)

            self?.presentViewController(mailVC, animated: true, completion: {
                SVProgressHUD.dismiss()
            })
        }
    }

    @IBAction func smsTextButtonPressed(sender: AnyObject) {
        if !MFMessageComposeViewController.canSendText() {
            MessageToUser.showDefaultErrorMessage(NSLocalizedString("Can't send message", comment: ""))

            return
        }

        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self

        if generatedShortURL == nil {
            SVProgressHUD.show()
        }

        generateShortURL { [weak self] (url, error) in
            SVProgressHUD.dismiss()

            guard let url = url where error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                return
            }

            messageVC.body = url

            self?.presentViewController(messageVC, animated: true, completion: {
                SVProgressHUD.dismiss()
            })
        }
    }

    @IBAction func moreButtonPressed(sender: AnyObject) {
        if generatedShortURL == nil {
            SVProgressHUD.show()
        }

        generateShortURL { [weak self] (url, error) in
            guard let url = url where error == nil else {
                MessageToUser.showDefaultErrorMessage(error?.localizedDescription)

                return
            }

            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

            self?.presentViewController(activityVC, animated: true, completion: {
                SVProgressHUD.dismiss()
            })
        }
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        if let onCancelPressed = onCancelPressed {
            onCancelPressed()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    //MARK: - Helpers
    func generateShortURL(completion: ((url: String?, error: NSError?) -> ())?) {
        if let url = generatedShortURL {
            completion?(url: url, error: nil)

            return
        }

        let branchUniversalObject = BranchUniversalObject(canonicalIdentifier: item?.objectId)
        branchUniversalObject.addMetadataKey("objectId", value: item?.objectId)

        if let item = item where item is Event {
            branchUniversalObject.addMetadataKey("type", value: "event")
        }

        let linkProperties = BranchLinkProperties()

        branchUniversalObject.getShortUrlWithLinkProperties(linkProperties, andCallback: { [weak self] (url: String?, error: NSError?) in
            completion?(url: url, error: error)
            self?.generatedShortURL = url
            })
    }

    //MARK: - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case MessageComposeResultCancelled:
            controller.dismissViewControllerAnimated(true, completion: nil)

        case MessageComposeResultSent:
            controller.dismissViewControllerAnimated(true, completion: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })

        case MessageComposeResultFailed:
            MessageToUser.showDefaultErrorMessage(NSLocalizedString("Failed to send mail", comment: ""))
            
        default:
            break
        }
    }

    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            fallthrough

        case MFMailComposeResultSaved:
            controller.dismissViewControllerAnimated(true, completion: nil)

        case MFMailComposeResultSent:
            controller.dismissViewControllerAnimated(true, completion: {
                self.dismissViewControllerAnimated(true, completion: nil)
            })

        case MFMailComposeResultFailed:
            MessageToUser.showDefaultErrorMessage(NSLocalizedString("Failed to send mail", comment: ""))

        default:
            break
        }
    }
}
