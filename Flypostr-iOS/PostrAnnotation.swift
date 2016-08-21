//
//  PostrAnnotation.swift
//  Flypostr-iOS
//
//  Created by Christian Schweig on 20.08.16.
//  Copyright © 2016 itcc. All rights reserved.
//

import UIKit
import MapKit

class PostrAnnotation: NSObject, MKAnnotation {
    
    var key: String?
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var authorId: String?
    var author: String?
    var imageId: String?
    var createdAt: String?
    
    init(key: String, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, authorId: String?, author: String?, imageId: String?, createdAt: String?) {
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.authorId = authorId
        self.author = author
        self.imageId = imageId
        self.createdAt = createdAt
    }
    
}