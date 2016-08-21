//
//  MeTableViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 20.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuthUI

class MeTableViewController: UITableViewController {
    
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var logout: UIButton!
//    @IBOutlet weak var deleteAccount: UIButton!
    
    var auth: FIRAuth?
    var authUI: FIRAuthUI?
    let users = FIRDatabase.database().referenceWithPath("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.auth = FIRAuth.auth()
        self.authUI = FIRAuthUI.authUI()
        
        self.pictureButton.imageView!.layer.cornerRadius = self.pictureButton.imageView!.frame.size.width / 2
        self.pictureButton.imageView!.clipsToBounds = true
        
        let profilePictureURL = auth?.currentUser?.photoURL
        if (profilePictureURL != nil) {
            if let data = NSData(contentsOfURL: profilePictureURL!) {
                let profilePictureImage = UIImage(data: data)
                self.pictureButton.setImage(profilePictureImage, forState: .Normal)
            }
        }
        
        displayName.text = auth?.currentUser?.displayName
        email.text = auth?.currentUser?.email
        
        let key = self.auth?.currentUser!.uid
        self.users.child(key!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.nickName.text = self.auth?.currentUser?.displayName
            } else {
                let postDict = snapshot.value as! [String : AnyObject]
                self.nickName.text = postDict["nick"] as! String?
            }
        })
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 2 && indexPath.row == 0) {
            let alertController = UIAlertController(title: "Change Nick Name", message: "Users can see your Nick Name on your Postrs", preferredStyle: UIAlertControllerStyle.Alert)
            let submitAction = UIAlertAction(title: "Save", style: .Default, handler: { (handler) -> Void in
                let nicknameTextField = alertController.textFields![0]
                let nicknameText = nicknameTextField.text!
                self.users.child(self.auth!.currentUser!.uid).setValue(["nick": nicknameText])
            })
            submitAction.enabled = false
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.placeholder = "Nick Name"
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                    submitAction.enabled = textField.text != ""
                })
            })
            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        do {
            try self.auth?.signOut()
        } catch {
            print("error")
        }
        
        self.performSegueWithIdentifier("quit", sender: nil)
    }
    
//    @IBAction func onDeleteAccount(sender: AnyObject) {
//        self.auth?.currentUser!.deleteWithCompletion { error in
//            if error != nil {
//                // An error happened.
//            } else {
//                // Account deleted.
//                self.performSegueWithIdentifier("quit", sender: nil)
//            }
//        }
//    }
    
    
}
