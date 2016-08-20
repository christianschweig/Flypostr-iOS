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
    var imageId: String?
    
    init(key: String, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D, imageId: String?) {
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.imageId = imageId
    }
    
}