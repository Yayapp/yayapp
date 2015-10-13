//
//  HappeningsViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class HappeningsViewController: UIViewController, ListEventsDelegate, EventChangeDelegate {

    @IBOutlet var upcoming: UIButton!
    @IBOutlet var past: UIButton!
    
    @IBOutlet var upcaomingUnderline: UIView!
    @IBOutlet var pastUnderline: UIView!
    
    @IBOutlet var container: UIView!
    
    var eventsData:[Event]!
    var activeViewController:ListEventsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        activeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
        activeViewController.delegate = self
        activeViewController!.view.frame = container.bounds
        container.addSubview(activeViewController!.view)
        activeViewController!.didMoveToParentViewController(self)
        upcoming(true)
    }

    
    @IBAction func upcoming(sender: AnyObject) {
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: true, block: {
            result, error in
            if error == nil {
                self.eventsData = result
                self.activeViewController.reloadAll(result!)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        pastUnderline.hidden = true
        upcaomingUnderline.hidden = false
        upcoming.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        past.titleLabel?.font = UIFont.systemFontOfSize(15)
    }
    
    @IBAction func past(sender: AnyObject) {
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: false, block: {
            result, error in
            if error == nil {
                self.eventsData = result
                self.activeViewController.reloadAll(result!)
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })
        pastUnderline.hidden = false
        upcaomingUnderline.hidden = true
        past.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        upcoming.titleLabel?.font = UIFont.systemFontOfSize(15)
    }
    
    func madeEventChoice(event:Event){
        let eventDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailsViewController") as! EventDetailsViewController
        eventDetailsViewController.event = event
        eventDetailsViewController.delegate = self
        self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
    }

    func eventChanged(event:Event) {
        self.activeViewController.events.reloadData()
    }
    
    func eventRemoved(event:Event) {
        eventsData = eventsData.filter({$0.objectId != event.objectId})
        self.activeViewController.reloadAll(eventsData!)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
