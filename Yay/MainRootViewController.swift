//
//  MainViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class MainRootViewController: UIViewController {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var changeViewTypeButton: UIButton!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var segments: UISegmentedControl!
    
    @IBOutlet weak var typeButton: UIButton!
    var currentVC:UIViewController!
    var isMapView = true
    var eventsData:[Event]!=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let font = UIFont.boldSystemFontOfSize(20.0)
        segments.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(),NSFontAttributeName:font], forState: UIControlState.Selected)
        segments.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        
        
//        segments.setBackgroundImage(UIImage(named: "submenu_highlightcolor"), forState: UIControlState.Selected , barMetrics: .Default)
//        typeButton.setImage(UIImage(named: "submenu_highlightcolor"), forState: UIControlState.Normal)
        segmentChanged(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func segmentChanged(sender: AnyObject) {
        var vc:EventsViewController
        if (isMapView) {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapEventsViewController") as! MapEventsViewController
        } else {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
        }
        if(segments.selectedSegmentIndex == 0) {
            ParseHelper.getTodayEvents({
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        } else {
            ParseHelper.getThisWeekEvents({
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        }
        
        updateActiveViewController(vc)
    }
    
    @IBAction func navigationDrawer(sender: AnyObject) {
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func showSettings(){
        performSegueWithIdentifier("settings", sender: nil)
    }
    
    @IBAction func changeViewType(sender: AnyObject) {
        changeViewTypeButton.tag = isMapView ? 1 : 0
        isMapView = changeViewTypeButton.tag == 0
        segmentChanged(true)
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
