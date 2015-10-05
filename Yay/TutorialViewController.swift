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
        appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
        tutorialImage.image = UIImage(named: "tut_\(pageIndex+1)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func skip(sender: AnyObject) {
        parentViewController!.dismissViewControllerAnimated(true, completion: {
        self.appDelegate.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
            })
    }

}
