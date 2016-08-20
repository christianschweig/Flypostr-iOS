//
//  MeTableViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 20.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI

class MeTableViewController: UITableViewController {

    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var deleteAccount: UIButton!

    var auth: FIRAuth?
    var authUI: FIRAuthUI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.auth = FIRAuth.auth()
        self.authUI = FIRAuthUI.authUI()
        
        self.pictureButton.imageView!.layer.cornerRadius = self.pictureButton.imageView!.frame.size.width / 2;
        self.pictureButton.imageView!.clipsToBounds = true;
        
        let profilePictureURL = auth?.currentUser?.photoURL
        if let data = NSData(contentsOfURL: profilePictureURL!) {
            let profilePictureImage = UIImage(data: data)
            self.pictureButton.setImage(profilePictureImage, forState: .Normal)
        }
        
        email.text = auth?.currentUser?.email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogout(sender: AnyObject) {
        do {
            try self.auth?.signOut()
        } catch {
             print("error")
        }
        
        self.performSegueWithIdentifier("quit", sender: nil)
    }
    
    @IBAction func onDeleteAccount(sender: AnyObject) {
        self.auth?.currentUser!.deleteWithCompletion { error in
            if error != nil {
                // An error happened.
            } else {
                // Account deleted.
                self.performSegueWithIdentifier("quit", sender: nil)
            }
        }
    }
    
    
}
