//
//  MapViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 19.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var locValue = CLLocationCoordinate2D()
    var array = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddView" {
            print ("suck my dick")
            var location = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
            (segue.destinationViewController as! AddFlyPostrViewController).location = location
        }
    }
    
}