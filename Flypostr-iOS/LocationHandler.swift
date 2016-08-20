//
//  LocationHandler.swift
//  Flypostr-iOS
//
//  Created by Simon Meier on 20.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class LocationHandler : NSObject, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    var array = NSMutableArray()
    let geoFire = GeoFire(firebaseRef: FIRDatabase.database().referenceWithPath("geofire"))
    
    override init() {
        super.init()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var newLocValue = manager.location!.coordinate
        
        //TODO only make a query (i.e. requests) if new location is significantly different to old location
        
        //Radius hardcoded to 600 meters
        //var circleQuery = geoFire.queryAtLocation(userLocation, withRadius: 100.00)
        let userLocation = CLLocation(latitude: newLocValue.latitude, longitude: newLocValue.longitude)
        let span = MKCoordinateSpanMake(0.800, 0.800)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        var regionQuery = geoFire.queryWithRegion(region)
        
        var queryHandleEntered = regionQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in

            var found = false
            for item in self.array {
                if (item as! CLLocation).coordinate.longitude == location.coordinate.longitude && (item as! CLLocation).coordinate.latitude == location.coordinate.latitude {
                    found = true
                    break
                }
            }
            if !found {
                self.array.addObject(location)
                let theInfo: NSDictionary = NSDictionary(object: self.array, forKey: "myArray")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshList", object: self, userInfo: theInfo as [NSObject : AnyObject])
            }
        })
        var queryHandleExited = regionQuery.observeEventType(.KeyExited, withBlock: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' exited the search area and is at location '\(location)'")
            self.array.removeObject(location)
            self.array.addObject(location)
            let theInfo: NSDictionary = NSDictionary(object: self.array, forKey: "myArray")
            NSNotificationCenter.defaultCenter().postNotificationName("refreshList", object: self, userInfo: theInfo as [NSObject : AnyObject])
        })
        
        let value = NSValue(MKCoordinate: self.locValue)
        let locValue: NSDictionary = NSDictionary(object: value, forKey: "locValue")
        NSNotificationCenter.defaultCenter().postNotificationName("refreshLocation", object: self, userInfo: locValue as [NSObject : AnyObject])
        
        self.locValue = newLocValue
    }

    
}