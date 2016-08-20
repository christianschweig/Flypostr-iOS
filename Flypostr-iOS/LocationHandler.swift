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

class LocationHandler: NSObject, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    var regionQuery = GFRegionQuery()
    var keyArray = NSMutableArray()
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
        
        let dummyLocation = CLLocation()
        let span = MKCoordinateSpanMake(0.800, 0.800)
        let region = MKCoordinateRegionMake(dummyLocation.coordinate, span)
        self.regionQuery = geoFire.queryWithRegion(region)
        
        self.regionQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            var found = false
            
            for item in self.keyArray {
                if (item as! String == key) {
                    found = true
                    break
                }
            }
            if !found {
                self.keyArray.addObject(key)
                let theInfo: NSDictionary = NSDictionary(object: self.keyArray, forKey: "myArray")
                NSNotificationCenter.defaultCenter().postNotificationName("refreshList", object: self, userInfo: theInfo as [NSObject : AnyObject])
            }
        })
        
        self.regionQuery.observeEventType(.KeyExited, withBlock: { (key: String!, location: CLLocation!) in
            print("Key '\(key)' exited the search area and is at location '\(location)'")
            self.keyArray.removeObject(key)
            let theInfo: NSDictionary = NSDictionary(object: self.keyArray, forKey: "myArray")
            NSNotificationCenter.defaultCenter().postNotificationName("refreshList", object: self, userInfo: theInfo as [NSObject : AnyObject])
        })
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = manager.location!.coordinate
        
        let userLocation = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
        let span = MKCoordinateSpanMake(0.800, 0.800)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        self.regionQuery.region = region
        
        let value = NSValue(MKCoordinate: newLocation)
        let locValue: NSDictionary = NSDictionary(object: value, forKey: "locValue")
        NSNotificationCenter.defaultCenter().postNotificationName("refreshLocation", object: self, userInfo: locValue as [NSObject : AnyObject])
    }
    
}