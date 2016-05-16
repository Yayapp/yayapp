//
//  InstructionViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 17.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class InstructionViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var backimage: UIImageView!

    var titleText : NSAttributedString!
    var imageName:String!

    override func viewDidLoad() {
        super.viewDidLoad()

        backimage.image = UIImage(named: imageName)
        titleLabel.attributedText = titleText
    }
}
