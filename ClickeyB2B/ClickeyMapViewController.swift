//
//  ClickeyMapViewController.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 05/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import MapKit

class ClickeyMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView?.delegate = self
        
        let netherlands = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.1326, 5.2913), MKCoordinateSpanMake(1,1))
        mapView?.setRegion(netherlands, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func cameraSetup() {
        mapView?.camera.altitude = 1400
        mapView?.camera.pitch = 50
        mapView?.camera.heading = 180
    }
}