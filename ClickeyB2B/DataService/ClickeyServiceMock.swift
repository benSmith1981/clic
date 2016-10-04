//
//  ClickeyServiceMock.swift
//  Clickey
//
//  Created by Berik Visschers on 11-03.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import MapKit

class ClickeyServiceMock {
    var globalErrorHandler: ((ErrorType, responseObject: AnyObject?) -> ())?
}

extension ClickeyServiceMock: ClickeyService {
    private func dataFrom(file: String, ofType type: String = "json") -> NSData {
        let bundle = NSBundle.mainBundle()
        
        let offlineFile = "SimulateServerResources/" + file
        guard let path = bundle.pathForResource(offlineFile, ofType: type) else {
            fatalError("No such file: \(offlineFile).\(type)")
        }
        
        guard let data = NSData(contentsOfFile: path) else {
            fatalError("Could not read \(path)")
        }
        
        return data
    }
    
    private func jsonFrom(file: String, ofType type: String = "json") -> AnyObject {
        let data = dataFrom(file, ofType: type)
        return try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    }
    
    // Mark: Checked
    
    func authenticate(username: String, password:String, handler: (HTTPResult<Void>) -> ()) {
        afterDelay {
            handler(.Success())
        }
    }
    
    func verifyUserName(userName:String, handler: (HTTPResult<Bool>) -> ()) {
        afterDelay { handler(.Success(true)) }
    }
    
    func verifyEmail(email:String, handler: (HTTPResult<Bool>) -> ()) {
        afterDelay { handler(.Success(true)) }
    }
    
    func verifyPassword(password:String, handler: (HTTPResult<Bool>) -> ()) {
        afterDelay { handler(.Success(true)) }
    }
    

    func getClickeys(handler: (HTTPResult<[ClickeyServerModel]>) -> ()) {
        afterDelay { handler(.Success([])) }
    }
    

    // Mark: Probably broken
    
    func logout(handler: (HTTPResult<Void>) -> ()){
        afterDelay { handler(.Success()) }
    }
    
    func startBLE(id:Int, handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func stopBLE(id:Int, handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func getLocation(id:Int, handler: (HTTPResult<(location: CLLocation, requestDate: NSDate, historical: Bool)>) -> ()) {
        let location = CLLocation(latitude: 52, longitude: 5)
        let result = (location: location, requestDate: NSDate(), historical: false)
        afterDelay { handler(.Success(result)) }
    }
    
    func registerUser(username: String, password: String, email: String, handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func getAllSubscription(handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func getClickeySubscription(id: Int, handler: (HTTPResult<NSDictionary>) -> ()) {
        afterDelay { handler(.Success([:])) }
    }
    
    func getAllSubscriptionSchemes(handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func getAllPaidSubscriptionSchemes(handler: (HTTPResult<[AnyObject]>) -> ()) {
        afterDelay { handler(.Success([])) }
    }
    
    func cancelSubcription(id: Int, handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func createSubcription(schemeID:Int, clickeyID:Int, handler: (HTTPResult<Void>) -> ()) {
        afterDelay { handler(.Success()) }
    }
    
    func registerClickey(image:UIImage?, clickeyUuid:String, name:String, description:String, icon:String, handler: (HTTPResult<Void>) -> ()){
        afterDelay { handler(.Success()) }
    }
    
    func registerForNotifications(deviceToken:String, handler: (HTTPResult<Void>) -> ()){
        afterDelay { handler(.Success()) }
    }
}