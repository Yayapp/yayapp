//
//  PopoverViewController.swift
//  Friendzi
//
//  Created by Yuriy B. on 5/4/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class PopoverViewController: UIViewController {
    static let storyboardID = "PopoverViewController"

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var arrowViewLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var submitButton: UIButton!
    @IBOutlet private weak var skipButton: UIButton!

    var arrowViewLeadingSpace: CGFloat?
    var text: String?
    var submitButtonTitle: String?
    var skipButtonHidden: Bool?
    var onSubmitPressed: (() -> ())?
    var onSkipPressed: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel.text = text
        submitButton.setTitle(submitButtonTitle, forState: .Normal)
        contentView.layer.masksToBounds = false
        contentView.layer.shadowOffset = CGSizeMake(0, 1)
        contentView.layer.shadowRadius = 2
        contentView.layer.shadowOpacity = 1

        skipButton.hidden = skipButtonHidden ?? false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        arrowViewLeadingSpaceConstraint.constant = arrowViewLeadingSpace ?? 0
    }

    @IBAction func submitButtonPressed(sender: UIButton) {
        onSubmitPressed?()
    }

    @IBAction func skipButtonPressed(sender: UIButton) {
        onSkipPressed?()
    }
}
