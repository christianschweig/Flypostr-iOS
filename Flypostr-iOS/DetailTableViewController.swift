//
//  DetailTableViewController.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 21.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class DetailTableViewController: UITableViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    var postr: PostrAnnotation!
    let storage = FIRStorage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = self.postr.title
        let storageRef = self.storage.reference(forURL: "gs://flypostr-cd317.appspot.com/images/")
        if (self.postr.imageId != nil) {
            let imageRef = storageRef.child(self.postr.imageId!)
            imageRef.data(withMaxSize: 1 * 2048 * 2048) { (data, error) -> Void in
                if (error != nil) {
                    print("Error: \(error)")
                } else {
                    let image: UIImage! = UIImage(data: data!)
                    self.image.image = image
                }
            }
        }
        self.message.text = self.postr!.subtitle
        self.author.text = self.postr!.author
        self.createdAt.text = self.postr!.createdAt
    }
    
}
