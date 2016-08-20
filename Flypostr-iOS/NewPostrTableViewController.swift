//
//  NewPostrTableViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 20.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewPostrTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newPostrImage: UIImageView!
    @IBOutlet weak var newPostrText: UITextField!
    @IBOutlet weak var newPostrMessage: UITextView!
    
    var location: CLLocationCoordinate2D?
    var newMedia: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPostrText.becomeFirstResponder()
    }
    
    @IBAction func onChangeImage(sender: AnyObject) {
        let changeImageMenu = UIAlertController(title: nil, message: "Select image from", preferredStyle: .ActionSheet)
        let cameraSelect = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Select")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                //imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newMedia = true
            } else {
                NSLog("Camera Select is not available on this device.")
            }
        })
        let cameraRollSelect = UIAlertAction(title: "Camera Roll", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Roll Select")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                //imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
                self.newMedia = false
            } else {
                NSLog("Camera Roll Select is not available on this device.")
            }
        })
        let cancelSelect = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        changeImageMenu.addAction(cameraSelect)
        changeImageMenu.addAction(cameraRollSelect)
        changeImageMenu.addAction(cancelSelect)
        presentViewController(changeImageMenu, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        newPostrImage.image = image
    }
    
    @IBAction func onSave(sender: AnyObject) {
        print("saved")
        
//        let userID = FIRAuth.auth()?.currentUser?.uid
//        
//        var now = NSDate()
//        var formatter = NSDateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
//        formatter.stringFromDate(now)
//        
//        
//        
//        // Create a reference to a Firebase location
//        var myRootRef = FIRDatabase.database().reference()
//        // Write data to Firebase
//        let key = myRootRef.child("postings").childByAutoId().key
//        let post : [NSObject : AnyObject] = ["authorId": userID, "commentCount": "0", "createdAt": formatter.stringFromDate(now), "imageId": "-id-image-001", "lat": location!.coordinate.latitude, "lng" : location!.coordinate.longitude, "modifiedAt": formatter.stringFromDate(now), "text": messageTextField.text!, "title": nameTextField.text!, "viewCount": "0"]
//        let childUpdates = ["/postings/\(key)": post]
//        
//        myRootRef.updateChildValues(childUpdates)
//        
//        let geoFire = GeoFire(firebaseRef: FIRDatabase.database().referenceWithPath("geofire"))
//        
//        geoFire.setLocation(location, forKey: key) {
//            (error) in
//            if (error != nil) {
//                print("An error occured: \(error)")
//            } else {
//                print("Saved location successfully!")
//            }
//        }
        
    }
    
    
}
