//
//  MapEventsViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

final class MapEventsViewController: EventsViewController, MKMapViewDelegate {

    @IBOutlet private weak var mapView: MKMapView?

    private let regionRadius: CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(MapEventsViewController.handleUserLogout),
                                                         name: Constants.userDidLogoutNotification,
                                                         object: nil)
        
        mapView?.delegate = self
        let user = ParseHelper.sharedInstance.currentUser
        if let location = user?.location,
            distance = user?.distance {
            let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.latitude , longitude: location.longitude)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(center, regionRadius * Double(distance), regionRadius * Double(distance))
            self.mapView?.setRegion(coordinateRegion, animated: true)
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
            self.mapView?.addAnnotation(annotationView.annotation!)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            annotationView!.canShowCallout = true

        } else {
            annotationView!.annotation = annotation
        }
        annotationView?.layer.masksToBounds = false
        let customPointAnnotation = annotation as! CustomPointAnnotation
        guard let event = customPointAnnotation.event else {
            return nil
        }

        ParseHelper.getData(event.photo, completion: { data, error in
            if error == nil {
                annotationView!.image = UIImage(data:data!)
                annotationView!.bounds.size.height = 30
                annotationView!.bounds.size.width = 30
                annotationView!.layer.cornerRadius = CGRectGetHeight(annotationView!.bounds) / 2
                annotationView!.layer.masksToBounds = true
                annotationView!.layer.borderColor = UIColor(red:0.32, green:0.72, blue:0.29, alpha:1.00).CGColor
                annotationView!.layer.borderWidth = 1.0
            } else {
                MessageToUser.showDefaultErrorMessage(error!.localizedDescription)
            }
        })

        return annotationView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        guard let customPointAnnotationEvent = (view.annotation as! CustomPointAnnotation).event else {
            return
        }

        delegate?.madeEventChoice(customPointAnnotationEvent)
    }
    
    override func eventChanged(event:Event) {
        reloadAll(eventsData)
    }
    
    override func eventRemoved(event:Event) {
        guard let annotation = mapView?.annotations else {
            return
        }
        mapView?.removeAnnotations(annotation)
        eventsData = eventsData.filter({$0.objectId != event.objectId})
        reloadAll(eventsData)
    }
    
    //MARK: - Notification Handlers
    func handleUserLogout() {
        reloadAll([])
    }
}
