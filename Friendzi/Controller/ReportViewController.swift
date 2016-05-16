//
//  ReportViewController.swift
//  Friendzi
//
//  Created by Yuriy Berdnikov on 5/3/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class ReportViewController: UIViewController {
    static let storyboardID = "reportViewController"

    @IBOutlet private weak var contentContainerView: UIView?
    @IBOutlet private weak var reportButton: UIButton?
    @IBOutlet private weak var blockButton: UIButton?

    var reportButtonTitle = "Report"
    var blockButtonTitle = "Block"

    var onReport: (() -> Void)?
    var onBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentContainerView?.layer.masksToBounds = false
        self.contentContainerView?.layer.shadowOffset = CGSizeMake(0, 0)
        self.contentContainerView?.layer.shadowRadius = 5
        self.contentContainerView?.layer.shadowOpacity = 0.5
        
        self.reportButton?.setTitle(reportButtonTitle, forState: .Normal)
        self.blockButton?.setTitle(blockButtonTitle, forState: .Normal)
    }
}

extension ReportViewController {
    //MARK:- IBActions
    @IBAction func reportButtonPressed(sender: UIButton) {
        self.onReport?()
        UIAlertController.showSimpleAlertViewWithText("Report was send and will be handled shorty.".localized,
                                                      title: "Report".localized,
                                                      controller: self,
                                                      completion: nil) { alertAction in
                                                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func blockButtonPressed(sender: UIButton) {
        self.onBlock?()
        UIAlertController.showSimpleAlertViewWithText("The user was blocked.".localized,
                                                      title: blockButtonTitle == "Block".localized ? "Blocked".localized : "Unblocked".localized,
                                                      controller: self,
                                                      completion: nil) { alertAction in
                                                        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }

    }

    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
