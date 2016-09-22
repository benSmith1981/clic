 //
//  UserRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


//MARK: - User APIService
class UserRequestManager{

    var newUser: Users?

    let APIService = APIServiceManager.sharedInstance
    
    static let sharedInstance = UserRequestManager()
    
    private init() {}
    
    private func genericUserRequest(httpmethodParam: httpMethods, path: String, body: BodyDataDictionary?, onCompletion: APIUserResponse){
        
        ///now post updated user data
        APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam, onCompletion: { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil)
                    return
                }
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.newUser)
                
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil)
            }
        })
    }
    
    /**
     Posts a new user to the server, part of the create new user flow, give a body with all the details such as mobile number (that must be unique) and then respond with new user object
     
     - parameter body: BodyDataDictionary, pass in a user body like this, mobile must be unique:
     {
     "firstName": "Ben",
     "lastName": "Quin",
     "mobileNumber": "+3161333999999",
     "nickname": "RQ"
     }
     - parameter onCompletion: APIUserResponse, Responds with the new user body and also server messages and success or fail
     */
    func login(body: BodyDataDictionary, onCompletion: APIUserResponse) {
        //create a password for the user
        var path = "" //not in user body need to hardcode
        genericUserRequest(httpMethods.post, path: path, body: body, onCompletion: onCompletion)
    }

}