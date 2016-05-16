//
//  TutorialViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 14.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class TutorialViewController: UIViewController {

    @IBOutlet private weak var tutorialImage: UIImageView!
    @IBOutlet private weak var tuorialButton: UIButton!

    private var pageIndex : Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialImage.image = UIImage(named: "tut_\(pageIndex + 1)")
    }

    @IBAction func skip(sender: AnyObject) {
        parentViewController!.dismissViewControllerAnimated(true, completion: {
        })
    }
}
