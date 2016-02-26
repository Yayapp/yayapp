//
//  MapEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class MapEventsViewController: EventsViewController, MKMapViewDelegate {

    
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

    
    override func reloadAll(events:[Event]) {
        eventsData = events
        
        for item in eventsData{
            
            
                let pointAnnoation = CustomPointAnnotation()
                
                pointAnnoation.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
                pointAnnoation.title = item.name
                pointAnnoation.subtitle = item.summary
                pointAnnoation.event = item
                let annotationView = MKPinAnnotationView(annotation: pointAnnoation, reuseIdentifier: "pin")
                self.mapView.addAnnotation(annotationView.annotation!)
            
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        var v = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if v == nil {
            v = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            v!.canShowCallout = true
        }
        else {
            v!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        
        
            customPointAnnotation.event.photo.getDataInBackgroundWithBlock({
                (data:NSData?, error:NSError?) in
                if(error == nil){
                    v!.image = UIImage(data:data!)
                    v!.bounds.size.height = 30
                    v!.bounds.size.width = 30
                } else {
                    MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
                }
            })
        
        return v
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let customPointAnnotation = view.annotation as! CustomPointAnnotation
        delegate!.madeEventChoice(customPointAnnotation.event)
    }
    
    override func eventChanged(event:Event) {
        reloadAll(eventsData)
    }
    
    override func eventRemoved(event:Event) {
        mapView.removeAnnotations(mapView.annotations)
        eventsData = eventsData.filter({$0.objectId != event.objectId})
        reloadAll(eventsData)
    }
}
