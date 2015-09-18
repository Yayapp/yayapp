//
//  TutorialViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 14.09.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    var hints:[String]!

    @IBOutlet weak var tutorialImage: UIImageView!
    @IBOutlet weak var tuorialButton: UIButton!
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        let suffix:Int = DeviceType.IS_IPHONE_4_OR_LESS ? 4 : DeviceType.IS_IPHONE_5 ? 5 : DeviceType.IS_IPHONE_6 ? 6 : 61
        tutorialImage.image = UIImage(named: "\(hints.first!)\(suffix)")
        Prefs.setPref(hints.first)
        hints.removeAtIndex(0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func skip(sender: AnyObject) {
        if hints.isEmpty {
            dismissViewControllerAnimated(true, completion: {
                appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
            })
        } else {
            let suffix:Int = DeviceType.IS_IPHONE_4_OR_LESS ? 4 : DeviceType.IS_IPHONE_5 ? 5 : DeviceType.IS_IPHONE_6 ? 6 : 61
            tutorialImage.image = UIImage(named: "\(hints.first!)\(suffix)")
            Prefs.setPref(hints.first)
            hints.removeAtIndex(0)
        }
    }

}
