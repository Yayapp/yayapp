//
//  ChooseLocationViewController.swift
//  Yay
//
//  Created by Nerses Zakoyan on 15.07.15.
//  Copyright (c) 2015 YAY LLC. All rights reserved.
//

import UIKit
import MapKit

class ChooseLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var mapView: MKMapView!
    var lat: CLLocationDegrees?
    var lon: CLLocationDegrees?
    let locationManager = CLLocationManager()
    var delegate: ChooseLocationDelegate!
    var touchMapCoordinate: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        locationManager.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        var longPressRecogniser = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        
        longPressRecogniser.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressRecogniser)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ok(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {
            if self.touchMapCoordinate != nil {
                self.delegate.madeLocationChoice(self.touchMapCoordinate)
            }
        })
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func handleLongPress(getstureRecognizer : UIGestureRecognizer){
        if getstureRecognizer.state != .Began { return }
        
        if self.mapView.annotations.count != 0{
            let annotation = self.mapView.annotations[0] as! MKAnnotation
            self.mapView.removeAnnotation(annotation)
        }
        
        let touchPoint = getstureRecognizer.locationInView(self.mapView)
        touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        mapView.addAnnotation(annotation)
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        
        if self.mapView.annotations.count != 0{
            let annotation = self.mapView.annotations[0] as! MKAnnotation
            self.mapView.removeAnnotation(annotation)
        }
        //2
        var localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                var alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            //3
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse.boundingRegion.center.latitude, longitude:     localSearchResponse.boundingRegion.center.longitude)
            
            self.touchMapCoordinate = pointAnnotation.coordinate
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = pointAnnotation.coordinate
            self.mapView.addAnnotation(pinAnnotationView.annotation)
        }
    }

}
protocol ChooseLocationDelegate : NSObjectProtocol {
    func madeLocationChoice(coordinates: CLLocationCoordinate2D)
}
