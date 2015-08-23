//
//  ListEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit

class ListEventsViewController: EventsViewController, UITableViewDataSource, UITableViewDelegate {

    var eventsFirst:[Event]?
    var currentTitle:String?
    let dateFormatter = NSDateFormatter()
    var currentLocation:CLLocation?
    
    @IBOutlet weak var events: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "EEE dd MMM 'at' H:mm"
        
        if currentTitle != nil {
            title = currentTitle!
        }
        
        let back = UIBarButtonItem(image:UIImage(named: "notifications_backarrow"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("backButtonTapped:"))
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
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    override func reloadAll(eventsList:[Event]) {
        eventsData = eventsList
        events.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = events.dequeueReusableCellWithIdentifier("Cell") as! EventsTableViewCell
        let event:Event! = eventsData[indexPath.row]
        let distanceBetween: CLLocationDistance = CLLocation(latitude: event.location.latitude, longitude: event.location.longitude).distanceFromLocation(currentLocation)
        let distanceStr = String(format: "%.2f", distanceBetween/1000)
        
        cell.title.text = event.name
        
//        cell.location.text = event.address
        cell.date.text = dateFormatter.stringFromDate(event.startDate)
        cell.howFar.text = distanceStr
        
        cell.picture.file = event.photo
        cell.picture.loadInBackground()
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let eventDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailsViewController") as! EventDetailsViewController
        eventDetailsViewController.event = eventsData[indexPath.row]
        
        navigationController?.pushViewController(eventDetailsViewController, animated: true)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}
