//
//  MainViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class MainRootViewController: UIViewController, ChooseCategoryDelegate {

    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var rightSwitchBarButtonItem:UIBarButtonItem?
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var segments: UISegmentedControl!
    
    @IBOutlet weak var createEvent: UIButton!
    
    var currentVC:UIViewController!
    var isMapView = true
    var eventsData:[Event]!=[]
    var chosenCategory:Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var buttonItems:[UIBarButtonItem]=[]
        
        if (PFUser.currentUser() != nil) {
            createEvent.hidden = false
            var rightChatBarButtonItem:UIBarButtonItem = UIBarButtonItem(image:UIImage(named: "topbar_chatico"), style: UIBarButtonItemStyle.Plain, target: self, action: "chatTapped:")
            rightChatBarButtonItem.tintColor = UIColor.whiteColor()
            buttonItems.append(rightChatBarButtonItem)
        }
            
        
        rightSwitchBarButtonItem = UIBarButtonItem(image:UIImage(named: "listico"), style: UIBarButtonItemStyle.Plain, target: self, action: "switchTapped:")
        rightSwitchBarButtonItem!.tintColor = UIColor.whiteColor()
        buttonItems.append(rightSwitchBarButtonItem!)
        
        self.navigationItem.setRightBarButtonItems(buttonItems, animated: true)
        
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
            ParseHelper.getTodayEvents(chosenCategory, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        } else {
            ParseHelper.getThisWeekEvents(chosenCategory, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        }
        
        updateActiveViewController(vc)
    }
    
    @IBAction func navigationDrawer(sender: AnyObject) {
        if (PFUser.currentUser() != nil) {
            appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
        } else {
            let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            navigationController?.pushViewController(loginViewController, animated: true)
        }
    }
    
    func showProfile(){
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfileViewController") as! UserProfileViewController
        vc.user = PFUser.currentUser()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSettings(){
        performSegueWithIdentifier("settings", sender: nil)
    }
    
    func showUpcomingEvents(){
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: true, block: {
            result, error in
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
            vc.eventsFirst = result
            vc.title = "UPCOMING EVENTS"
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func showPastEvents(){
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: false, block: {
            result, error in
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
            vc.eventsFirst = result
            vc.title = "PAST EVENTS"
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @IBAction func openCategoryPicker(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ChooseCategoryViewController") as! ChooseCategoryViewController
        vc.delegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func madeCategoryChoice(category: Category) {
        chosenCategory = category
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

    func switchTapped(sender:UIButton) {
        isMapView = !isMapView
        if isMapView {
            rightSwitchBarButtonItem!.image = UIImage(named: "listico")
        } else {
            rightSwitchBarButtonItem!.image = UIImage(named: "mapmarkerico")
        }
        segmentChanged(true)
    }
   
    func chatTapped (sender:UIButton) {
        println("add pressed")
    }

}
