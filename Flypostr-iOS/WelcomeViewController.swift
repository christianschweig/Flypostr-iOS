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
    
    /** @fn authUI:didSignInWithUser:error:
     @brief Message sent after the sign in process has completed to report the signed in user or
     error encountered.
     @param authUI The @c FIRAuthUI instance sending the messsage.
     @param user The signed in user if the sign in attempt was successful.
     @param error The error that occured during sign in, if any.
     */
    public func authUI(_ firAuthUI: FIRAuthUI, didSignInWith user: FIRUser?, error: Error?) {
        print("something happened");
        authUI = firAuthUI
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.auth = FIRAuth.auth()
        self.authUI = FIRAuthUI.authUI()
        self.authUI?.delegate = self
        
        let kGoogleAppClientID = (FIRApp.defaultApp()?.options.clientID)!
        let kFacebookAppID = "174114339679066"
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
    
    override func viewDidAppear(_ animated: Bool) {
        print("photourl")
        print(auth?.currentUser?.photoURL)
        print(auth?.currentUser?.email)
        //if ((auth?.currentUser?.email) != nil) {
        //  self.performSegue(withIdentifier: "go", sender: nil)
        //} else {
        if authUI != nil {
            self.performSegue(withIdentifier: "go", sender: nil)
        } else {
            let controller = self.authUI!.authViewController()
            self.present(controller, animated: true, completion: nil)
        }
    }
    
//    override func viewWillUnload() {
//        if let handle = self.authStateDidChangeHandle {
//            self.auth?.removeAuthStateDidChangeListener(handle)
//        }
//    }
    
    @IBAction func onClick(_ sender: AnyObject) {
        if ((auth?.currentUser?.email) != nil) {
            self.performSegue(withIdentifier: "go", sender: nil)
        } else {
            let controller = self.authUI!.authViewController()
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func authUI(_ authUI: FIRAuthUI, didSignInWith user: FIRUser?, error: NSError?) {
        self.performSegue(withIdentifier: "go", sender: nil)
    }

}
