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
import FirebaseStorage
import FirebaseAuthUI

class NewPostrTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newPostrImage: UIImageView!
    @IBOutlet weak var newPostrText: UITextField!
    @IBOutlet weak var newPostrMessage: UITextView!
    
    var location: CLLocationCoordinate2D?
    var newMedia: Bool?
    let geoFire = GeoFire(firebaseRef: FIRDatabase.database().referenceWithPath("geofire"))
    let postings = FIRDatabase.database().referenceWithPath("postings")
    let users = FIRDatabase.database().referenceWithPath("users")
    var image = UIImage()
    
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
        self.image = image
        newPostrImage.image = self.image
    }
    
    @IBAction func onSave(sender: AnyObject) {
        
        let now = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = NSTimeZone(name: "Europe/Vaduz")
        
        //Re-size Images
        let originalImage = self.image
        var imageId = ""
        print(originalImage.size.width)
        
        if (originalImage.size.height > 0) {
            let destinationSizeImage: CGSize = CGSize(width: 900, height: 900)
            UIGraphicsBeginImageContext(destinationSizeImage)
            originalImage.drawInRect(CGRectMake(0, 0, destinationSizeImage.width, destinationSizeImage.height))
            let imageImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            
            let destinationSizeThumbnail: CGSize = CGSize(width: 124, height: 124)
            UIGraphicsBeginImageContext(destinationSizeThumbnail)
            originalImage.drawInRect(CGRectMake(0, 0, destinationSizeThumbnail.width, destinationSizeThumbnail.height))
            let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            
            //Upload Images
            let storage = FIRStorage.storage()
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            let imageUuid = NSUUID().UUIDString
            let imageFileName = "/" + imageUuid + ".jpg"
            imageId = imageUuid + ".jpg"
            
            let imageData: NSData = UIImageJPEGRepresentation(imageImage, 1.0)!
            let imagesStorageRef = storage.referenceForURL("gs://flypostr-cd317.appspot.com/images/")
            let imageRef = imagesStorageRef.child(imageFileName)
            
            // Upload the file to the path "images/rivers.jpg"
            /*let uploadTask = */imageRef.putData(imageData, metadata: metadata) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    //let downloadURL = metadata!.downloadURL
                }
            }
            
            let thumbnailData: NSData = UIImageJPEGRepresentation(thumbnailImage, 1.0)!
            let thumbnailsStorageRef = storage.referenceForURL("gs://flypostr-cd317.appspot.com/thumbnails/")
            let thumbnailRef = thumbnailsStorageRef.child(imageFileName)
            
            // Upload the file to the path "images/rivers.jpg"
            /*let uploadTask = */thumbnailRef.putData(thumbnailData, metadata: metadata) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    //let downloadURL = metadata!.downloadURL
                }
            }
        }
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        var userName = ""
        self.users.child(userId!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                userName = (FIRAuth.auth()?.currentUser?.displayName)!
                
                //Save Posting
                let key = self.postings.childByAutoId().key
                print("unten \(userName)")
                let post: [NSObject : AnyObject] = ["authorId": userId!, "author": userName, /*"commentCount": "0", */"createdAt": formatter.stringFromDate(now), "imageId": imageId, "lat": self.location!.latitude, "lng" : self.location!.longitude, /*"modifiedAt": formatter.stringFromDate(now), */"text": self.newPostrMessage.text!, "title": self.newPostrText.text!/*, "viewCount": "0"*/]
                let childUpdates = ["/\(key)": post]
                self.postings.updateChildValues(childUpdates)
                
                //Save GeoFire
                let oLocation = CLLocation(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
                self.geoFire.setLocation(oLocation, forKey: key) {
                    (error) in
                    if (error != nil) {
                        let ac = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                
            } else {
                let postDict = snapshot.value as! [String : AnyObject]
                userName = (postDict["nick"] as! String?)!
                
                //Save Posting
                let key = self.postings.childByAutoId().key
                print("unten \(userName)")
                let post: [NSObject : AnyObject] = ["authorId": userId!, "author": userName, /*"commentCount": "0", */"createdAt": formatter.stringFromDate(now), "imageId": imageId, "lat": self.location!.latitude, "lng" : self.location!.longitude, /*"modifiedAt": formatter.stringFromDate(now), */"text": self.newPostrMessage.text!, "title": self.newPostrText.text!/*, "viewCount": "0"*/]
                let childUpdates = ["/\(key)": post]
                self.postings.updateChildValues(childUpdates)
                
                //Save GeoFire
                let oLocation = CLLocation(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
                self.geoFire.setLocation(oLocation, forKey: key) {
                    (error) in
                    if (error != nil) {
                        let ac = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
}
