//
//  Clickey.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 05/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//
import MapKit

class Clickey: NSObject, MKAnnotation {
    let title: String!
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}