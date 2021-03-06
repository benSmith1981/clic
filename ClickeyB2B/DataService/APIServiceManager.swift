 //
//  APIServiceManager.swift
//  Yona
//
//  Created by Ben Smith on 31/03/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation
import SystemConfiguration

public typealias BodyDataDictionary = [String: AnyObject]

class APIServiceManager {
    
    static let sharedInstance = APIServiceManager()
    enum responseCodes: Int{
        case ok200 = 200
        case ok399 = 399
        case connectionFail400 = 400
        case connectionFail499 = 499
        case serverProblem500 = 500
        case serverProblem599 = 599
        case yonaErrorCode = 600
        case internalErrorCode = 700
    }

    enum responseMessages: String{
        case networkConnectionProblem = "Network connection problem"
        case serverProblem = "Server problem"
        case YonaError = "Clickey Problem"
        case internalErrorMessage = "App error"
        case success = "Success"
    }
    
    struct serverMessages{
        static let timeoutRequest = "The request timed out, server problem"
        static let OK = "OK"
        static let networkConnectionProblem = "Network connection problem"
        static let serverProblem = "Server problem"
        static let noJsonReturned = "No JSON returned from request"
        static let FailedToRetrievePassword = "Failed to get user password"
        static let FailedToRetrieveGetUserDetails = "Failed to get user details"

    }
    
    enum errorDomains : String {
        case yonaErrorDomain = "Clickey.Domain"
        case networkErrorDomain = "Network.Domain"
        case successDomain = "Success"
        case internalErrorDomain = "App error"
    }
    
    struct YonaErrorTypes {
        static let UserRequestFailed = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: serverMessages.FailedToRetrieveGetUserDetails ?? "Unknown Error"])
        static let UserPasswordRequestFail = NSError.init(domain: errorDomains.internalErrorDomain.rawValue, code: responseCodes.internalErrorCode.rawValue, userInfo:  [NSLocalizedDescriptionKey: serverMessages.FailedToRetrievePassword ?? "Unknown Error"])
        static let Success = NSError.init(domain: errorDomains.successDomain.rawValue, code: responseCodes.ok200.rawValue, userInfo:  [NSLocalizedDescriptionKey: "OK" ?? "Unknown Error"])
    }
    
    private init() {}
    
    /**
     Calls the manager to make a standard http request using the httpHeader json type, this requires the users password that is stored in the keychain:
        ["Content-Type": "application/json", "Yona-Password": yonaPassword]
     
     - parameter body: BodyDataDictionary?, the body of the req uest required by some calls, can be nil
     - parameter path: String, the path to the API service call
     - parameter httpMethod: httpMethods, the httpmethod enum (post, get , put, delete)
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func callRequestWithAPIServiceResponse(body: BodyDataDictionary?, path: String, httpMethod: httpMethods, onCompletion:APIServiceResponse){
        
        guard let yonaPassword =  KeychainManager.sharedInstance.getYonaPassword() else {
            onCompletion(false,nil, YonaErrorTypes.UserPasswordRequestFail)
            return
        }
        
        let langId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String
        let countryId = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as! String
        let language = "\(langId)-\(countryId)"
        
        let httpHeader = ["Content-Type": "application/json", "Accept-Language": language, "Yona-Password": yonaPassword]
        Manager.sharedInstance.makeRequest(path, body: body, httpMethod: httpMethod, httpHeader: httpHeader, onCompletion: onCompletion)
    }
    
    /**
     Setups up the messages from the server so the UI knows what is going wrong or right
     
     - parameter json:BodyDataDictionary?, the body of the messages from server, if there is an error then there is a message or code key in response
     - parameter error: NSError?, the http response code we need to check (200-204 success, other is fail
     - return requestResult A struct used for error requests containing our codes and messages of the error
     */
    func setServerCodeMessage(json:BodyDataDictionary?, error: NSError?) -> requestResult{
        //If there is a json response and we have the key Error then we know there is and
        if let jsonUnwrapped = json,
            let message = jsonUnwrapped["message"] as? String{
            if let serverCode = jsonUnwrapped["code"] as? String{
                return requestResult.init(success: false, errorMessage: message, errorCode: responseCodes.yonaErrorCode.rawValue, domain: serverCode)
            }
        } else if let error = error {
            //for any error between 500 to 599 return server problem, else return network error
            if case responseCodes.serverProblem500.rawValue ... responseCodes.serverProblem599.rawValue = error.code {
                return requestResult.init(success: false, errorMessage: responseMessages.serverProblem.rawValue, errorCode: error.code, domain: errorDomains.networkErrorDomain.rawValue)
            } else {
                //if there is possibly any other just return the systems error
                return requestResult.init(success: false, errorMessage: responseMessages.networkConnectionProblem.rawValue, errorCode: error.code, domain: errorDomains.networkErrorDomain.rawValue)
            }
        }
        //success so return that with a success domain
        return requestResult.init(success: true, errorMessage: responseMessages.success.rawValue, errorCode: responseCodes.ok200.rawValue, domain: errorDomains.successDomain.rawValue)
    }
    
    

    /**
     This determines the title of the error from the error code so the user is presented this in a friendly way
     
     - parameter error: NSError? the error object
     - return The error string from the error code, this will either be a Yona error, so something failed on their side to do with the requets or a network problem
     */
    func determineErrorCode(error: NSError?) -> String {
        var errorString = ""
        if case responseCodes.yonaErrorCode.rawValue = error!.code {
            //if we have a yona error then it's error code string will be it's domain which is passed back from YONA and is used to determine how UI works
            errorString = (error?.domain)!
        } else if case responseCodes.internalErrorCode.rawValue = error!.code {
            errorString = responseMessages.internalErrorMessage.rawValue
        } else if case responseCodes.connectionFail400.rawValue ... responseCodes.serverProblem599.rawValue = error!.code {
            errorString = responseMessages.networkConnectionProblem.rawValue
        } else if case -1103 ... -998 = error!.code {
            errorString = responseMessages.networkConnectionProblem.rawValue
        }else {
            errorString = responseMessages.success.rawValue
        }
        return errorString
    }
    
}