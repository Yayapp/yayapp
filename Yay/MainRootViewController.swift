//
//  MainViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class MainRootViewController: UIViewController {

    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var segments: UISegmentedControl!
    
    var currentVC:UIViewController!
    var isMapView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentChanged(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func segmentChanged(sender: AnyObject) {
        var vc:UIViewController
        switch (segments.selectedSegmentIndex) {
        case 0: vc = self.storyboard!.instantiateViewControllerWithIdentifier("TodaysEventsViewController") as!TodaysEventsViewController
        case 1:
            if isMapView {
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapEventsViewController") as!MapEventsViewController
                segments.setTitle("List", forSegmentAtIndex: 1)
                isMapView = false
            } else {
                vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as!ListEventsViewController
                segments.setTitle("Map", forSegmentAtIndex: 1)
                isMapView = true
            }
        case 2: vc = self.storyboard!.instantiateViewControllerWithIdentifier("ThisWeekViewController") as!ThisWeekViewController
            
        default:
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("TodaysEventsViewController") as!TodaysEventsViewController
            }
        
        
        updateActiveViewController(vc)
    }
    
    func removeInactiveViewController(inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMoveToParentViewController(nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    func updateActiveViewController(activeViewController: UIViewController?) {
        if activeViewController != nil {
            addChildViewController(activeViewController!)
            activeViewController!.view.frame = container.bounds
            container.addSubview(activeViewController!.view)
            activeViewController!.didMoveToParentViewController(self)
            
        }
        removeInactiveViewController(currentVC)
        currentVC = activeViewController
    }


}
