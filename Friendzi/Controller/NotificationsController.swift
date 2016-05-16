//
//  NotificatiosController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 10.02.16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

final class NotificationsController: UIViewController {
    
    var currentVC:UIViewController!
    
    @IBOutlet private weak var container: UIView?
    @IBOutlet private weak var recentUnderline: UIView?
    @IBOutlet private weak var chatUnderline: UIView?
    @IBOutlet private weak var requestsUnderline: UIView?
    @IBOutlet private weak var recentButton: UIButton?
    @IBOutlet private weak var chatButton: UIButton?
    @IBOutlet private weak var requestsButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(NotificationsController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)

        recentAction(true)
        
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
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
            activeViewController!.view.frame = container?.bounds ?? CGRect.zero
            if let view = activeViewController?.view {
                container?.addSubview(view)
            }
            activeViewController!.didMoveToParentViewController(self)

        }
        removeInactiveViewController(currentVC)
        currentVC = activeViewController
    }
    
    @IBAction func recentAction(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("RecentViewController") as? RecentViewController else {
            return
        }

        updateActiveViewController(vc)
        recentUnderline?.hidden = false
        chatUnderline?.hidden = true
        requestsUnderline?.hidden = true
        recentButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        chatButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        requestsButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func chatAction(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("ConversationsTableViewController") as? ConversationsTableViewController else {
            return
        }

        updateActiveViewController(vc)
        recentUnderline?.hidden = true
        chatUnderline?.hidden = false
        requestsUnderline?.hidden = true
        recentButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        chatButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
        requestsButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func requestsAction(sender: AnyObject) {
        guard let vc = UIStoryboard.main()?.instantiateViewControllerWithIdentifier("RequestsTableViewController") as? RequestsTableViewController else {
            return
        }
        updateActiveViewController(vc)
        recentUnderline?.hidden = true
        chatUnderline?.hidden = true
        requestsUnderline?.hidden = false
        recentButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        chatButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        requestsButton?.setTitleColor(Color.PrimaryActiveColor, forState: UIControlState.Normal)
    }

    //MARK: - Notification Handlers
    func handleUserLogout() {
        recentAction(true)
    }
}
