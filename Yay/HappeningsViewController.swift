//
//  HappeningsViewController.swift
//  Friendzi
//
//  Created by Nerses Zakoyan on 25.08.15.
//  Copyright (c) 2015 KrazyLabs LLC. All rights reserved.
//

import UIKit

class HappeningsViewController: UIViewController, ListEventsDelegate {

    @IBOutlet weak var upcoming: UIButton!
    @IBOutlet weak var past: UIButton!
    
    @IBOutlet weak var upcaomingUnderline: UIView!
    @IBOutlet weak var pastUnderline: UIView!
    
    @IBOutlet weak var container: UIView!
    
    var activeViewController:ListEventsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = UIColor(red:CGFloat(3/255.0), green:CGFloat(118/255.0), blue:CGFloat(114/255.0), alpha: 1)
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        activeViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ListEventsViewController") as! ListEventsViewController
        activeViewController.delegate = self
        activeViewController!.view.frame = container.bounds
        container.addSubview(activeViewController!.view)
        activeViewController!.didMoveToParentViewController(self)
        upcoming(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upcoming(sender: AnyObject) {
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: true, block: {
            result, error in
            self.activeViewController.reloadAll(result!)
        })
        pastUnderline.hidden = true
        upcaomingUnderline.hidden = false
        upcoming.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        past.titleLabel?.font = UIFont.systemFontOfSize(15)
    }
    
    @IBAction func past(sender: AnyObject) {
        ParseHelper.getUpcomingPastEvents(PFUser.currentUser()!, upcoming: false, block: {
            result, error in
            self.activeViewController.reloadAll(result!)
        })
        pastUnderline.hidden = false
        upcaomingUnderline.hidden = true
        past.titleLabel?.font = UIFont.boldSystemFontOfSize(15)
        upcoming.titleLabel?.font = UIFont.systemFontOfSize(15)
    }
    
    func madeEventChoice(event:Event){
        let eventDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailsViewController") as! EventDetailsViewController
        eventDetailsViewController.event = event
        self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
