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
import FirebaseStorage

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentPosition = CLLocationCoordinate2D()
    var regionQuery = GFRegionQuery()
    var keyArray = NSMutableArray()
    var annotationArray = [PostrAnnotation]()
    let geoFire = GeoFire(firebaseRef: FIRDatabase.database().reference(withPath: "geofire"))
    let postings = FIRDatabase.database().reference(withPath: "postings")
    var postrToPass = PostrAnnotation(key: "", title: "", subtitle: "", coordinate: CLLocation().coordinate, authorId: "", author: "", imageId: "", createdAt: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let logoImageView = UIImageView(image: UIImage(named: "flypostr"))
        //        self.navigationItem.titleView = logoImageView
        
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
        self.regionQuery = (geoFire?.query(with: region))!
        
        
        self.regionQuery.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            print("Key '\(key)' entered the search area and is at location '\(location)'")
            
            var found = false
            
            for item in self.keyArray {
                if (item as! String == key) {
                    found = true
                    break
                }
            }
            if !found {
                self.keyArray.add(key)
                
                self.geoFire!.getLocationForKey(key! as String, withCallback: { (location, error) in
                    if (error != nil) {
                        print("An error occurred getting the location for \(key): \(error?.localizedDescription)")
                    } else if (location != nil) {
                        print("Location for \(key) is [\(location?.coordinate.latitude), \(location?.coordinate.longitude)]")
                        
                        let postrAnno = PostrAnnotation(key: (key)!, title: "", subtitle: "", coordinate: location!.coordinate, authorId: "", author: "", imageId: "", createdAt: "")
                        
                        self.postings.child(key!).observe(FIRDataEventType.value, with: { (snapshot) in
                            let postDict = snapshot.value as! [String : AnyObject]
                            postrAnno.title = postDict["title"] as! String?
                            postrAnno.subtitle = postDict["text"] as! String?
                            postrAnno.authorId = postDict["authorId"] as! String?
                            postrAnno.author = postDict["author"] as! String?
                            postrAnno.imageId = postDict["imageId"] as! String?
                            postrAnno.createdAt = postDict["createdAt"] as! String?
                            self.mapView.addAnnotation(postrAnno)
                            self.annotationArray.append(postrAnno)
                        })
                    } else {
                        print("GeoFire does not contain a location for \"firebase-hq\"")
                    }
                })
                
            }
        })
        self.regionQuery.observe(.keyExited, with: { (key: String?, location: CLLocation?) in
            print("Key '\(key)' exited the search area and is at location '\(location)'")
            var index = 0
            for item: PostrAnnotation in self.annotationArray {
                if (item.key == key) {
                    self.mapView.removeAnnotation(item)
                    self.annotationArray.remove(at: index)
                }
                index = index + 1
            }
            self.keyArray.remove(key)
        })
        mapView.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = manager.location!.coordinate
        self.currentPosition = newLocation
        
        let userLocation = CLLocation(latitude: newLocation.latitude, longitude: newLocation.longitude)
        let span = MKCoordinateSpanMake(0.800, 0.800)
        let region = MKCoordinateRegionMake(userLocation.coordinate, span)
        self.regionQuery.region = region
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "itcc"
        
        if annotation is PostrAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if (annotationView == nil) {
                annotationView = MKPinAnnotationView(annotation: annotation as! PostrAnnotation, reuseIdentifier: identifier)
                annotationView!.canShowCallout = true
                
                let postrAnno = annotation as! PostrAnnotation
                let storage = FIRStorage.storage()
                let storageRef = storage.reference(forURL: "gs://flypostr-cd317.appspot.com/thumbnails/")
                print(postrAnno.imageId)
                if (postrAnno.imageId != nil) {
                    let imageRef = storageRef.child(postrAnno.imageId!)
                    imageRef.data(withMaxSize: 1 * 2048 * 2048) { (data, error) -> Void in
                        if (error != nil) {
                            print("Error while downloading some Firebase Storage")
                        } else {
                            let image: UIImage! = UIImage(data: data!)
                            let imageView = UIImageView(image: image)
                            imageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
                            annotationView?.leftCalloutAccessoryView = imageView
                        }
                    }
                }
                let btn = UIButton(type: UIButtonType.detailDisclosure)
                annotationView!.rightCalloutAccessoryView = btn
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annotation = view.annotation as! PostrAnnotation
        self.postrToPass = annotation
        self.performSegue(withIdentifier: "showDetails", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createNewPostr" {
            let location = self.currentPosition
            let targetNavContr = segue.destination as! UINavigationController
            (targetNavContr.childViewControllers[0] as! NewPostrTableViewController).location = location
        } else if segue.identifier == "showDetails" {
            let targetController = segue.destination as! DetailTableViewController
            targetController.postr = self.postrToPass
        }
    }
    
    @IBAction func unwindToMapViewController(_ segue: UIStoryboardSegue) {
        
    }
    
}
