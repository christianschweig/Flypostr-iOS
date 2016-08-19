//
//  AddFlyPostrViewController.swift
//  Flypostr-iOS
//
//  Created by Simon Meier on 19.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddFlyPostrViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    var location : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddButtonClicked(sender: UIButton) {
        
        var now = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.stringFromDate(now)
        
        // Create a reference to a Firebase location
        var myRootRef = FIRDatabase.database().reference()
        // Write data to Firebase
        let key = myRootRef.child("postingsDetail").childByAutoId().key
        let post = ["title": nameTextField.text!, "author": "user01","thumbnail": "-id-thumbnail-001","createTime": formatter.stringFromDate(now), "lastActivityTime": formatter.stringFromDate(now)]
        let childUpdates = ["/postingsDetail/\(key)": post]
        
        myRootRef.updateChildValues(childUpdates)
        
        let geoFire = GeoFire(firebaseRef: FIRDatabase.database().referenceWithPath("geoLocation"))
        
        geoFire.setLocation(location, forKey: key) {
            (error) in
            if (error != nil) {
                print("An error occured: \(error)")
            } else {
                print("Saved location successfully!")
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
}