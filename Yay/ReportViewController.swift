//
//  ReportViewController.swift
//  Friendzi
//
//  Created by Yuriy Berdnikov on 5/3/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    static let storyboardID = "reportViewController"
    
    @IBOutlet private var contentContainerView: UIView!
    @IBOutlet private var reportButton: UIButton!
    @IBOutlet private var blockButton: UIButton!
    
    var reportButtonTitle = "Report"
    var blockButtonTitle = "Block"
    
    var onReport: (() -> Void)?
    var onBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.contentContainerView.layer.masksToBounds = false
        self.contentContainerView.layer.shadowOffset = CGSizeMake(0, 0)
        self.contentContainerView.layer.shadowRadius = 5
        self.contentContainerView.layer.shadowOpacity = 0.5
        
        self.reportButton.setTitle(reportButtonTitle, forState: .Normal)
        self.blockButton.setTitle(blockButtonTitle, forState: .Normal)
    }
}

extension ReportViewController {
    
    @IBAction func reportButtonPressed(sender: UIButton) {
        self.onReport?()
    }
    
    @IBAction func blockButtonPressed(sender: UIButton) {
        self.onBlock?()
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
