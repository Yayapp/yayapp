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
    
    var thisWeekCenter:NSLayoutConstraint!
    var todayCenter:NSLayoutConstraint!
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var container: UIView!

    @IBOutlet weak var thisWeek: UIButton!
    
    @IBOutlet weak var today: UIButton!
    @IBOutlet weak var createEvent: UIButton!
    
    var currentVC:UIViewController!
    var isMapView = false
    var eventsData:[Event]!=[]
    var chosenCategory:Category?
    var selectedSegment:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thisWeekCenter = NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: thisWeek, attribute: .CenterX, multiplier: 1, constant: 0)
        todayCenter = NSLayoutConstraint(item: view, attribute: .CenterX, relatedBy: .Equal, toItem: today, attribute: .CenterX, multiplier: 1, constant: 0)
    
        var buttonItems:[UIBarButtonItem]=[]
        
        if (PFUser.currentUser() != nil) {
            createEvent.hidden = false
            var rightChatBarButtonItem:UIBarButtonItem = UIBarButtonItem(image:UIImage(named: "topbar_chatico"), style: UIBarButtonItemStyle.Plain, target: self, action: "chatTapped:")
            rightChatBarButtonItem.tintColor = UIColor(red:CGFloat(170/255.0), green:CGFloat(170/255.0), blue:CGFloat(170/255.0), alpha: 1)
            buttonItems.append(rightChatBarButtonItem)
        }
            
        
        rightSwitchBarButtonItem = UIBarButtonItem(image:UIImage(named: "mapmarkerico"), style: UIBarButtonItemStyle.Plain, target: self, action: "switchTapped:")
        rightSwitchBarButtonItem!.tintColor = UIColor(red:CGFloat(170/255.0), green:CGFloat(170/255.0), blue:CGFloat(170/255.0), alpha: 1)
        buttonItems.append(rightSwitchBarButtonItem!)
        
        self.navigationItem.setRightBarButtonItems(buttonItems, animated: true)
        
//        let font = UIFont.boldSystemFontOfSize(20.0)
//        segments.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(),NSFontAttributeName:font], forState: UIControlState.Selected)
//        segments.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        
        
//        segments.setBackgroundImage(UIImage(named: "submenu_highlightcolor"), forState: UIControlState.Selected , barMetrics: .Default)
//        typeButton.setImage(UIImage(named: "submenu_highlightcolor"), forState: UIControlState.Normal)
        today(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func segmentChanged() {
        var vc:EventsViewController
        if (isMapView) {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("MapEventsViewController") as! MapEventsViewController
        } else {
            vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
        }
        if(selectedSegment == 0) {
            ParseHelper.getTodayEvents(PFUser.currentUser(), category: chosenCategory, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        } else {
            ParseHelper.getThisWeekEvents(PFUser.currentUser(), category: chosenCategory, block: {
                (eventsList:[Event]?, error:NSError?) in
                if(error == nil) {
                    vc.reloadAll(eventsList!)
                }
            })
        }
        
        updateActiveViewController(vc)
    }
    
    @IBAction func today(sender: AnyObject) {
        selectedSegment = 0
        thisWeek.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        today.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        view.removeConstraint(thisWeekCenter)
        view.addConstraint(todayCenter)
        view.bringSubviewToFront(thisWeek)
        segmentChanged()
    }
    
    @IBAction func thisWeek(sender: AnyObject) {
        selectedSegment = 1
        thisWeek.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        today.titleLabel?.font = UIFont.systemFontOfSize(15.0)
        view.removeConstraint(todayCenter)
        view.addConstraint(thisWeekCenter)
        view.bringSubviewToFront(today)
        segmentChanged()
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
            vc.currentTitle = "UPCOMING EVENTS"
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func showPastEvents(){
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: false, block: {
            result, error in
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
            vc.eventsFirst = result
            vc.currentTitle = "PAST EVENTS"
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
        segmentChanged()
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
        segmentChanged()
    }
   
    func chatTapped (sender:UIButton) {
        let controller: ConversationListViewController = ConversationListViewController(layerClient: appDelegate.layerClient)
        navigationController?.pushViewController(controller, animated: true)
    }

}
