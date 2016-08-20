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
    //var array = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.showPins(_:)), name:"refreshList", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.refreshLocation(_:)), name:"refreshLocation", object: nil)
    }
    
    func showPins(notification: NSNotification) {
        var array = notification.userInfo!["myArray"] as! NSArray;
        var annoArray = [MKAnnotation]()
        self.mapView.removeAnnotations(mapView.annotations)
        for item in array {
            let annoItem = MKPointAnnotation()
            annoItem.coordinate = item.coordinate
            annoArray.append(annoItem)
        }
        self.mapView.showAnnotations(annoArray, animated: true)
    }
    
    func refreshLocation(notification: NSNotification) {
        var test = notification.userInfo!["locValue"] as! NSValue
        locValue = test.MKCoordinateValue
        //locValue
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
        */
        
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddView" {
            var location = CLLocation(latitude: self.locValue.latitude, longitude: self.locValue.longitude)
            (segue.destinationViewController as! AddFlyPostrViewController).location = location
        }
    }
    
}