//
//  ClickeyMapViewController.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 05/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
import MapKit

class ClickeyMapViewController: UIViewController, ClickeyServiceConsumer, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView?
    var appDelegate: AppDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        mapView?.delegate = self
        
        let netherlands = MKCoordinateRegionMake(CLLocationCoordinate2DMake(52.1326, 5.2913), MKCoordinateSpanMake(1,1))
        mapView?.setRegion(netherlands, animated: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getDevices", name: "getDevices", object: nil)
        service.getClickeys { result in
            if let clickeys = result.object {
                self.appDelegate.clickeyList = clickeys
                for clickey in self.appDelegate.clickeyList {
//                    if let coord = clickey.location {
//                        let clickeyAnnotation = Clickey.init(title: clickey.name, locationName: clickey.desc , coordinate: coord.coordinate)
//                        self.mapView?.addAnnotation(clickeyAnnotation)
//                    }
                    
                    let clickeyAnnotation = Clickey.init(title: clickey.name, locationName: clickey.desc , coordinate: CLLocationCoordinate2DMake(52.1326, 5.2913))
                    self.mapView?.addAnnotation(clickeyAnnotation)
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func cameraSetup() {
        mapView?.camera.altitude = 1400
        mapView?.camera.pitch = 50
        mapView?.camera.heading = 180
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Clickey {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func getDevices(){
        service.getClickeys { result in
            if let clickeys = result.object {
                self.appDelegate.clickeyList = clickeys
                for clickey in self.appDelegate.clickeyList {
                    let clickeyAnnotation = Clickey.init(title: "", locationName: clickey.desc , coordinate: clickey.location.coordinate)
                    self.mapView?.addAnnotation(clickeyAnnotation)
                }
            }
        }
    }
}