//
//  MapEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class MapEventsViewController: EventsViewController, MKMapViewDelegate, EventChangeDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        let user = PFUser.currentUser()
        
        let location:PFGeoPoint? = user?.objectForKey("location") as? PFGeoPoint
        let distance = user?.objectForKey("distance") as? Double
        if location != nil {
            let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location!.latitude , longitude: location!.longitude)
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(center, regionRadius * distance!, regionRadius * distance!)
            
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func reloadAll(events:[Event]) {
        eventsData = events
        
        for item in eventsData{
            
            item.category.fetchInBackgroundWithBlock({
                (result, error) in
                let pointAnnoation = CustomPointAnnotation()
                
                pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
                pointAnnoation.title = item.name
                pointAnnoation.subtitle = item.summary
                pointAnnoation.event = item
                let annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
                self.mapView.addAnnotation(annotationView.annotation)
            })
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
        
        var v = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if v == nil {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            v.canShowCallout = true
        }
        else {
            v.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        let image = customPointAnnotation.event.category["icon"] as! PFFile
        
        if image.isDataAvailable {
            v.image = UIImage(data:image.getData()!)
            v.bounds.size.height = 30
            v.bounds.size.width = 30
        } else {
            image.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil){
                    v.image = UIImage(data:data!)
                    v.bounds.size.height = 30
                    v.bounds.size.width = 30
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        }
        return v
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let customPointAnnotation = view.annotation as! CustomPointAnnotation
        let eventDetailsViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailsViewController") as! EventDetailsViewController
        eventDetailsViewController.event = customPointAnnotation.event
        eventDetailsViewController.delegate = self
        
        navigationController?.pushViewController(eventDetailsViewController, animated: true)
    }
    
    func eventChanged(event:Event) {
        reloadAll(eventsData)
    }
    
    func eventRemoved(event:Event) {
        mapView.removeAnnotations(mapView.annotations)
        eventsData = eventsData.filter({$0.objectId != event.objectId})
        reloadAll(eventsData)
    }
}
