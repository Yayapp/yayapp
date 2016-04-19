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

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MapEventsViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)

        mapView.delegate = self
        let user = ParseHelper.sharedInstance.currentUser
        
        if let location = user?.location,
        distance = user?.distance {
            let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude , longitude: location.longitude)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(center, regionRadius * Double(distance), regionRadius * Double(distance))
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
        
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: Constants.userDidLogoutNotification,
                                                            object: nil)
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

        ParseHelper.getData(customPointAnnotation.event.photo, completion: {
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

    //MARK: - Notification Handlers
    func handleUserLogout() {
        reloadAll([])
    }
}
