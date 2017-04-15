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
    let geoFire = GeoFire(firebaseRef: FIRDatabase.database().reference(withPath: "geofire"))
    let postings = FIRDatabase.database().reference(withPath: "postings")
    let users = FIRDatabase.database().reference(withPath: "users")
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPostrText.becomeFirstResponder()
    }
    
    @IBAction func onChangeImage(_ sender: AnyObject) {
        let changeImageMenu = UIAlertController(title: nil, message: "Select image from", preferredStyle: .actionSheet)
        let cameraSelect = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Select")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                //imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
                self.newMedia = true
            } else {
                NSLog("Camera Select is not available on this device.")
            }
        })
        let cameraRollSelect = UIAlertAction(title: "Camera Roll", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Roll Select")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                //imagePicker.mediaTypes = [kUTTypeImage as NSString]
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
                self.newMedia = false
            } else {
                NSLog("Camera Roll Select is not available on this device.")
            }
        })
        let cancelSelect = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        changeImageMenu.addAction(cameraSelect)
        changeImageMenu.addAction(cameraRollSelect)
        changeImageMenu.addAction(cancelSelect)
        present(changeImageMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil)
        self.image = image
        newPostrImage.image = self.image
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(identifier: "Europe/Vaduz")
        
        //Re-size Images
        let originalImage = self.image
        var imageId = ""
        print(originalImage.size.width)
        
        if (originalImage.size.height > 0) {
            let destinationSizeImage: CGSize = CGSize(width: 900, height: 900)
            UIGraphicsBeginImageContext(destinationSizeImage)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: destinationSizeImage.width, height: destinationSizeImage.height))
            let imageImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            
            let destinationSizeThumbnail: CGSize = CGSize(width: 124, height: 124)
            UIGraphicsBeginImageContext(destinationSizeThumbnail)
            originalImage.draw(in: CGRect(x: 0, y: 0, width: destinationSizeThumbnail.width, height: destinationSizeThumbnail.height))
            let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
            
            //Upload Images
            let storage = FIRStorage.storage()
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            let imageUuid = UUID().uuidString
            let imageFileName = "/" + imageUuid + ".jpg"
            imageId = imageUuid + ".jpg"
            
            let imageData: Data = UIImageJPEGRepresentation(imageImage!, 1.0)!
            let imagesStorageRef = storage.reference(forURL: "gs://flypostr-cd317.appspot.com/images/")
            let imageRef = imagesStorageRef.child(imageFileName)
            
            // Upload the file to the path "images/rivers.jpg"
            /*let uploadTask = */imageRef.put(imageData, metadata: metadata) { metadata, error in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    //let downloadURL = metadata!.downloadURL
                }
            }
            
            let thumbnailData: Data = UIImageJPEGRepresentation(thumbnailImage!, 1.0)!
            let thumbnailsStorageRef = storage.reference(forURL: "gs://flypostr-cd317.appspot.com/thumbnails/")
            let thumbnailRef = thumbnailsStorageRef.child(imageFileName)
            
            // Upload the file to the path "images/rivers.jpg"
            /*let uploadTask = */thumbnailRef.put(thumbnailData, metadata: metadata) { metadata, error in
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
        self.users.child(userId!).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                userName = (FIRAuth.auth()?.currentUser?.displayName)!
                
                //Save Posting
                let key = self.postings.childByAutoId().key
                print("unten \(userName)")
                let post: [AnyHashable: Any] = ["authorId": userId!, "author": userName, /*"commentCount": "0", */"createdAt": formatter.string(from: now), "imageId": imageId, "lat": self.location!.latitude, "lng" : self.location!.longitude, /*"modifiedAt": formatter.stringFromDate(now), */"text": self.newPostrMessage.text!, "title": self.newPostrText.text!/*, "viewCount": "0"*/]
                let childUpdates = ["/\(key)": post]
                self.postings.updateChildValues(childUpdates)
                
                //Save GeoFire
                let oLocation = CLLocation(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
                self.geoFire?.setLocation(oLocation, forKey: key) {
                    (error) in
                    if (error != nil) {
                        let ac = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            } else {
                let postDict = snapshot.value as! [String : AnyObject]
                userName = (postDict["nick"] as! String?)!
                
                //Save Posting
                let key = self.postings.childByAutoId().key
                print("unten \(userName)")
                let post: [AnyHashable: Any] = ["authorId": userId!, "author": userName, /*"commentCount": "0", */"createdAt": formatter.string(from: now), "imageId": imageId, "lat": self.location!.latitude, "lng" : self.location!.longitude, /*"modifiedAt": formatter.stringFromDate(now), */"text": self.newPostrMessage.text!, "title": self.newPostrText.text!/*, "viewCount": "0"*/]
                let childUpdates = ["/\(key)": post]
                self.postings.updateChildValues(childUpdates)
                
                //Save GeoFire
                let oLocation = CLLocation(latitude: (self.location?.latitude)!, longitude: (self.location?.longitude)!)
                self.geoFire?.setLocation(oLocation, forKey: key) {
                    (error) in
                    if (error != nil) {
                        let ac = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    
}
