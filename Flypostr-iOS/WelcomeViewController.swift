//
//  WelcomeViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 20.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI

class WelcomeViewController: UIViewController, FIRAuthUIDelegate {

    var auth: FIRAuth?
    var authUI: FIRAuthUI?
//  var authStateDidChangeHandle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.auth = FIRAuth.auth()
        self.authUI = FIRAuthUI.authUI()
        self.authUI?.delegate = self
        
        let kGoogleAppClientID = (FIRApp.defaultApp()?.options.clientID)!
        let kFacebookAppID = ""
        let providers: [FIRAuthProviderUI] = [FIRGoogleAuthUI(clientID: kGoogleAppClientID)!, FIRFacebookAuthUI(appID: kFacebookAppID)!]
        self.authUI?.signInProviders = providers
        
//        self.authStateDidChangeHandle = self.auth?.addAuthStateDidChangeListener { auth, user in
//            if let user = user {
//                // User is signed in.
//                self.performSegueWithIdentifier("go", sender: nil)
//            } else {
//                // No user is signed in.
//                let controller = self.authUI!.authViewController()
//                self.presentViewController(controller, animated: true, completion: nil)
//            }
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print("photourl")
        print(auth?.currentUser?.photoURL)
        if ((auth?.currentUser?.email) != nil) {
            self.performSegueWithIdentifier("go", sender: nil)
        } else {
            let controller = self.authUI!.authViewController()
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
//    override func viewWillUnload() {
//        if let handle = self.authStateDidChangeHandle {
//            self.auth?.removeAuthStateDidChangeListener(handle)
//        }
//    }
    
    @IBAction func onClick(sender: AnyObject) {
        if ((auth?.currentUser?.email) != nil) {
            self.performSegueWithIdentifier("go", sender: nil)
        } else {
            let controller = self.authUI!.authViewController()
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func authUI(authUI: FIRAuthUI, didSignInWithUser user: FIRUser?, error: NSError?) {
        self.performSegueWithIdentifier("go", sender: nil)
    }

}
