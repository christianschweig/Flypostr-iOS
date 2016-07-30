//
//  MapViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 30.07.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var test =  //FromURL("https://flypostr-cd317.firebaseio.com/")
        let geoFire = GeoFire(firebaseRef: FIRDatabase.database().reference())
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        //mapView.showsUserLocation = true
    }

    
    @IBAction func onAdd(sender: AnyObject) {
        print("hallo")
        let annotation = MKPointAnnotation()
        annotation.title = "Title"
        annotation.subtitle = "Subtitle"
        annotation.coordinate = self.locValue
        self.mapView.addAnnotation(annotation)
        self.mapView.showAnnotations([annotation], animated: true)
        
        let annotationView = MKAnnotationView()
        annotationView.annotation = annotation
        annotationView.canShowCallout = true
        annotationView.enabled = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locValue = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
}


