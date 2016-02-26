//
//  TutorialViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 14.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
//    var hints:[String]!
    var pageIndex : Int = 0

    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tuorialButton: UIButton!
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialImage.image = UIImage(named: "tut_\(pageIndex+1)")
        
    }

    
    @IBAction func skip(sender: AnyObject) {
        parentViewController!.dismissViewControllerAnimated(true, completion: {
            })
    }

}
