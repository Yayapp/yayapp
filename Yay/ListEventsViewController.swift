//
//  ListEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

protocol ListEventsDelegate : NSObjectProtocol {
    func madeEventChoice(event: Event)
}

class ListEventsViewController: EventsViewController, UITableViewDataSource, UITableViewDelegate, EventChangeDelegate {

    var eventsFirst:[Event]?
    var currentTitle:String?
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation?
    var delegate:ListEventsDelegate?
    
    @IBOutlet var events: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        if currentTitle != nil {
            title = currentTitle!
        }
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
        back.tintColor = Color.PrimaryActiveColor
        self.navigationItem.setLeftBarButtonItem(back, animated: false)
        
        if let user = PFUser.currentUser() {
            let currentPFLocation = user.objectForKey("location") as! PFGeoPoint
            currentLocation = CLLocation(latitude: currentPFLocation.latitude, longitude: currentPFLocation.longitude)
        } else {
            currentLocation = CLLocation(latitude: TempUser.location!.latitude, longitude: TempUser.location!.longitude)
        }
        
        events.delegate = self
        events.dataSource = self
        
        if (eventsFirst != nil) {
            reloadAll(eventsFirst!)
        }
    }
   

    override func reloadAll(eventsList:[Event]) {
        eventsData = eventsList
        events.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = events.dequeueReusableCellWithIdentifier("Cell") as! EventsTableViewCell
        let event:Event! = eventsData[indexPath.row]
        let cllocation = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude)
        let distanceBetween: CLLocationDistance = cllocation.distanceFromLocation(currentLocation!)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        
        cell.title.text = event.name
        
        cllocation.getLocationString(cell.location, button: nil, timezoneCompletion: nil)
        
        cell.date.text = dateFormatter.stringFromDate(event.startDate)
        cell.howFar.text = "\(distanceStr)km"
        
        cell.picture.file = event.photo
        cell.picture.loadInBackground()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.height/2
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(delegate != nil) {
            delegate!.madeEventChoice(eventsData[indexPath.row])
        } else {
            let eventDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailsViewController") as! EventDetailsViewController
            eventDetailsViewController.event = eventsData[indexPath.row]
            eventDetailsViewController.delegate = self
            self.navigationController?.pushViewController(eventDetailsViewController, animated: true)
        }
    }
    
    func eventChanged(event:Event) {
        events.reloadData()
    }
    
    func eventRemoved(event:Event) {
        eventsData = eventsData.filter({$0.objectId != event.objectId})
        events.reloadData()
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}

