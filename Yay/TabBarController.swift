//
//  TabBarController.swift
//  Friendzi
//
//  Created by Yuriy B. on 4/1/16.
//  Copyright © 2016 KrazyLabs LLC. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let eventsController = UIStoryboard(name: "EventsTab", bundle: nil).instantiateViewControllerWithIdentifier("eventsNavigationController")
        let groupsController = UIStoryboard(name: "GroupsTab", bundle: nil).instantiateViewControllerWithIdentifier("groupsNavigationController")
        let createEventController = UIStoryboard(name: "CreateEventTab", bundle: nil).instantiateViewControllerWithIdentifier("createEventNavigationController")
        let notificationsController = UIStoryboard(name: "NotificationsTab", bundle: nil).instantiateViewControllerWithIdentifier("notificationsNavigationController")
        let profileController = UIStoryboard(name: "ProfileTab", bundle: nil).instantiateViewControllerWithIdentifier("profileNavigationController")

        viewControllers = [eventsController, groupsController,createEventController, notificationsController, profileController]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
