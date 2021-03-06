//
//  Manager.swift
//  Yona
//
//  Created by Ben Smith on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

typealias ServerMessage = String
typealias ServerCode = String
typealias APIResponse = (Bool, ServerMessage?, ServerCode?) -> Void
typealias APIServiceResponse = (Bool, BodyDataDictionary?, NSError?) -> Void

enum httpMethods: String{
    case post = "POST"
    case delete = "DELETE"
    case get = "GET"
    case put = "PUT"
}

class Manager: NSObject {

    static let sharedInstance = Manager()
    var userInfo:BodyDataDictionary = [:]

    private override init() {
        print("Only initialised once only")
    }
    /**
     Helper method to create an NSURLRequest with it's required httpHeader, httpBody and the httpMethod request and return it to be executed
     
     - parameter path: String,
     - parameter body: BodyDataDictionary?,
     - parameter httpHeader: [String:String],
     - parameter httpMethod: httpMethods
     - parameter NSURLRequest, the request created to be executed by makeRequest
     */
    func setupRequest(path: String, body: BodyDataDictionary?, httpHeader: [String:String], httpMethod: httpMethods) throws -> NSURLRequest {
        let urlString = path.hasPrefix(EnvironmentManager.baseUrlString()) ? path : EnvironmentManager.baseUrlString() + path
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.allHTTPHeaderFields = httpHeader //["Content-Type": "application/json", "Yona-Password": password]

        if let body = body {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
        }
    
        request.timeoutInterval = 30
        
        request.HTTPMethod = httpMethod.rawValue
        
        return request
    }
    
}

//MARK: - User Manager methods
extension Manager {
    
    /**
     This is a generic method that can make any request to YONA API. It creates a request with the given parameters and an NSURLSession, then executes the session and gets the responses passing it back as a dictionary and a success or fail of the operation. The body is optional as some request do not require it.
     
     - parameter path: String, The required path to the API service that the user wants to access
     - parameter body: BodyDataDictionary?, The data dictionary of [String: AnyObject] type
     - parameter httpMethod: httpMethods, the http methods that you can do on the API stored in the enum
     - parameter httpHeader:[String:String], the header set to a JSON type
     - parameter onCompletion:APIServiceResponse The response from the API service, giving success or fail, dictionary response and any error
     */
    func makeRequest(path: String, body: BodyDataDictionary?, httpMethod: httpMethods, httpHeader:[String:String], onCompletion: APIServiceResponse)
    {
        do{
            let request = try setupRequest(path, body: body, httpHeader: httpHeader, httpMethod: httpMethod)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                if error != nil{
                    dispatch_async(dispatch_get_main_queue()) {
                        onCompletion(false, nil, error)
                        return
                    }
                }
                if response != nil{
                    if data != nil && data?.length > 0{ //don't try to parse 0 data, even tho it isn't nil
                        do{
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(jsonData  as? BodyDataDictionary, error: error)
                            let userInfo = [
                                NSLocalizedDescriptionKey: requestResult.errorMessage ?? "Unknown Error"
                            ]
                            let omdbError = NSError(domain: requestResult.domain, code: requestResult.errorCode, userInfo: userInfo)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                onCompletion(requestResult.success, jsonData as? BodyDataDictionary, omdbError)
                            }
                        } catch let error as NSError{
                            dispatch_async(dispatch_get_main_queue()) {
                                onCompletion(false, nil, error)
                                return
                            }
                        }
                    } else {
                        let requestResult = APIServiceManager.sharedInstance.setServerCodeMessage(nil, error: error)
                        //This passes back the errors we retrieve, looks in the different optionals which may or may not be nil
                        let userInfo = [
                            NSLocalizedDescriptionKey: requestResult.errorMessage ?? "Unknown Error"
                        ]
                        let omdbError = NSError(domain: requestResult.domain, code: requestResult.errorCode, userInfo: userInfo)
                        dispatch_async(dispatch_get_main_queue()) {
                            onCompletion(requestResult.success, nil, omdbError)
                        }
                    }
                }
            })
            task.resume()
        } catch let error as NSError{
            dispatch_async(dispatch_get_main_queue()) {
                onCompletion(false, nil, error)
            }
            
        }
    }

}