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
    let users = FIRDatabase.database().reference(withPath: "users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.auth = FIRAuth.auth()
        self.authUI = FIRAuthUI.authUI()
        
        self.pictureButton.imageView!.layer.cornerRadius = self.pictureButton.imageView!.frame.size.width / 2
        self.pictureButton.imageView!.clipsToBounds = true
        
        let profilePictureURL = auth?.currentUser?.photoURL
        if (profilePictureURL != nil) {
            if let data = try? Data(contentsOf: profilePictureURL!) {
                let profilePictureImage = UIImage(data: data)
                self.pictureButton.setImage(profilePictureImage, for: UIControlState())
            }
        }
        
        displayName.text = auth?.currentUser?.displayName
        email.text = auth?.currentUser?.email
        
        let key = self.auth?.currentUser!.uid
        self.users.child(key!).observe(FIRDataEventType.value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.nickName.text = self.auth?.currentUser?.displayName
            } else {
                let postDict = snapshot.value as! [String : AnyObject]
                self.nickName.text = postDict["nick"] as! String?
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if (indexPath.section == 2 && indexPath.row == 0) {
            let alertController = UIAlertController(title: "Change Nick Name", message: "Users can see your Nick Name on your Postrs", preferredStyle: UIAlertControllerStyle.alert)
            let submitAction = UIAlertAction(title: "Save", style: .default, handler: { (handler) -> Void in
                let nicknameTextField = alertController.textFields![0]
                let nicknameText = nicknameTextField.text!
                self.users.child(self.auth!.currentUser!.uid).setValue(["nick": nicknameText])
            })
            submitAction.isEnabled = false
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "Nick Name"
                NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { (notification) -> Void in
                    submitAction.isEnabled = textField.text != ""
                })
            })
            alertController.addAction(submitAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onLogout(_ sender: AnyObject) {
        do {
            try self.auth?.signOut()
        } catch {
            print("error")
        }
        
        self.performSegue(withIdentifier: "quit", sender: nil)
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
