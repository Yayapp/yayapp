//
//  ShareEventHintViewController.swift
//  Friendzi
//
//  Created by Yuriy B. on 5/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class ShareEventHintViewController: UIViewController {
    static let storyboardID = "ShareEventHintViewController"

    var event: Event?
    var onCancelPressed: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func inviteButtonPressed(sender: UIButton) {
        guard let shareItemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ShareItemViewController.storyboardID) as? ShareItemViewController else {
            return
        }

        shareItemVC.modalPresentationStyle = .OverCurrentContext
        shareItemVC.modalTransitionStyle = .CrossDissolve
        shareItemVC.item = event

        presentViewController(shareItemVC, animated: true, completion: nil)
    }

    @IBAction func skipButtonPressed(sender: UIButton) {
        if let onCancelPressed = onCancelPressed {
            onCancelPressed()
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
