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
    var array = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.showPins(_:)), name:"refreshList", object: nil)
    }

    func showPins(notification: NSNotification) {
        var annoArray = [MKAnnotation]()
        for item in self.array {
            let annoItem = MKPointAnnotation()
            annoItem.coordinate = item.coordinate
            annoArray.append(annoItem)
        }
        self.mapView.showAnnotations(annoArray, animated: true)
    }
    
    func showNewPin(location: CLLocation) {
        let annoItem = MKPointAnnotation()
        annoItem.coordinate = location.coordinate
        self.mapView.addAnnotation(annoItem)
    }
    
    
    @IBAction func onAdd(sender: AnyObject) {
        //show window
        self.performSegueWithIdentifier("showAddView", sender: self)
        
        /*
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
        
        //var test =  //FromURL("https://flypostr-cd317.firebaseio.com/")
        let geoFire = GeoFire(firebaseRef: FIRDatabase.database().reference())
        let location = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
        
        geoFire.setLocation(location, forKey: "dummy") {
            (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
            }
        }
        */
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locValue = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        //TODO only make a query (i.e. requests) if new location is significantly different to old location
        
        let userLocation = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
        let geoFire = GeoFire(firebaseRef: FIRDatabase.database().reference())
        
        //Radius hardcoded to 600 meters
        //var circleQuery = geoFire.queryAtLocation(userLocation, withRadius: 100.00)
        
        let span = MKCoordinateSpanMake(0.800, 0.800)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        var regionQuery = geoFire.queryWithRegion(region)
        
        var queryHandleEntered = regionQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            var found = false
            for item in self.array {
                if (item as! CLLocation).coordinate.longitude == location.coordinate.longitude && (item as! CLLocation).coordinate.latitude == location.coordinate.latitude {
                    found = true
                    break
                }
            }
            if !found {
                self.array.addObject(location)
                self.self.showNewPin(location)
            }
            /*
            if !self.array.containsObject(location) {
                self.array.addObject(location)
            }
            */
        })
        var queryHandleExited = regionQuery.observeEventType(.KeyExited, withBlock: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' exited the search area and is at location '\(location)'")
            self.array.removeObject(location)
        })
        
        let theInfo: NSDictionary = NSDictionary(object: self.array, forKey: "myArray")
        //NSNotificationCenter.defaultCenter().postNotificationName("refreshList", object: self, userInfo: theInfo as [NSObject : AnyObject])
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddView" {
            print ("suck my dick")
            var location = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
            (segue.destinationViewController as! AddFlyPostrViewController).location = location
        }
    }
    
}


