//
//  ChooseLocationViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

protocol ChooseLocationDelegate : NSObjectProtocol {
    func madeLocationChoice(coordinates: CLLocationCoordinate2D)
}

final class ChooseLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    static let storyboardID = "ChooseLocationViewController"
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var mapView: MKMapView!

    private var lat: CLLocationDegrees?
    private var lon: CLLocationDegrees?
    private let locationManager = CLLocationManager()
    private var touchMapCoordinate: CLLocationCoordinate2D?

    weak var delegate: ChooseLocationDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(ChooseLocationViewController.handleLongPress(_:)))
        
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }
    
    @IBAction func ok(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            if let coordinate = self.touchMapCoordinate {
                self.delegate.madeLocationChoice(coordinate)
            }
        })
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        if self.mapView.annotations.count != 0 {
            for annonation in self.mapView.annotations {
                if let annonation = annonation as? MKPointAnnotation {
                    self.mapView.removeAnnotation(annonation)
                }
            }
        }
        
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        if let coordinate = self.touchMapCoordinate {
            annotation.coordinate = coordinate
        }

        mapView.addAnnotation(annotation)
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        
        if self.mapView.annotations.count != 0{
            let annotation = self.mapView.annotations[0] 
            self.mapView.removeAnnotation(annotation)
        }
        //2
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            //3
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            self.touchMapCoordinate = pointAnnotation.coordinate
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            self.mapView.addAnnotation(pinAnnotationView.annotation!)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = mapView.dequeueReusableAnnotationViewWithIdentifier("myPin") as? MKPinAnnotationView ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")

        pin.animatesDrop = true
        pin.draggable = true

        return pin
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            mapView.showsUserLocation = false
        }
    }
}

