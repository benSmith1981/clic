//
//  ClickeyServiceImplementation.swift
//  Clickey
//
//  Created by Berik Visschers on 11-03.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import MapKit

private extension ClickeyService {
    var restPath:       String { return "rest/v1/" }
    var clickeyPref:       String { return "clickey/" }
    var clickeyStatus: String { return "?states=true" }
    //Authentication
    var oAuthTokenURL:  String { return Constants.baseURL + "oauth/token" }
    var logoutURL:  String { return Constants.baseURL + restPath + "oauth/logout/" }
    
    //Clickey Management
    var clickeyListURL: String { return Constants.baseURL + restPath + clickeyPref + "overview?states=true" }
    func startBLEURL(id:Int) -> String { return Constants.baseURL + restPath + clickeyPref + String(id) + "/bluetooth/start" }
    func stopBLEURL(id:Int) -> String { return Constants.baseURL + restPath + clickeyPref + String(id) + "/bluetooth/stop" }
    func locationURL(id:Int) -> String { return Constants.baseURL + restPath + clickeyPref + String(id) + "/location" }
    
    //User Registration
    var registerURL: String { return Constants.baseURL + restPath + "service/registration/"}
    var userNameVerificationURL:    String { return registerURL + "username/validation/" }
    var emailVerificationURL:    String { return registerURL + "email/validation/" }
    var passwordVerificationURL:    String { return registerURL + "password/validation/" }
    
    //Clickey Registration
    var registerClickeyURL: String { return Constants.baseURL + restPath + clickeyPref + "registration"}
    
    //Clickey Subscription
    var subscriptionSchemeURL: String { return Constants.baseURL + restPath +  "subscription-schemes/"}
    var subscriptionPaidSchemeURL: String { return Constants.baseURL + restPath +  "subscription-schemes/paid"}
    var subscriptionURL: String { return Constants.baseURL + restPath + "subscription/"}
    var clickeySubscriptionURL: String { return subscriptionURL + "clickey/"}
    var createSubscriptionURL: String { return subscriptionURL + "create/"}
    var cancelSubscriptionURL: String { return subscriptionURL + "cancel/"}
    
    //Push Notification /rest/v1/notification/registerDevice/{deviceType}/{appUuid}/{appToken}
    func notificationURL(deviceToken:String, uuid:String) -> String { return Constants.baseURL + restPath + "notification/registerDevice/IOS/\(uuid)/\(deviceToken)/" }
}

class ClickeyServiceURLSession: NSObject, NSURLSessionTaskDelegate {
    var globalErrorHandler: ((ErrorType, responseObject: AnyObject?) -> ())?

    let timeout = NSTimeInterval(60)
    var token: String?
    
    private lazy var session: NSURLSession = {
        return NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self,
            delegateQueue: NSOperationQueue.mainQueue())
    }()
    
    func stringFromParameters(parameters: HTTPParametersType) -> String {
        var keyValueSets = [String]()
        
        for (key, value) in parameters {
            keyValueSets.append(key.urlEscaped + "=" + value.urlEscaped)
        }
        
        return keyValueSets.joinWithSeparator("&")
    }
    
    private func request(
        method: HTTPMethod,
        var url: String,
        parameters: HTTPParametersType? = nil,
        body: NSData? = nil,
        var headers: Dictionary<String, String> = [:],
        handler: (HTTPResult<AnyObject?>) -> ()) -> NSURLSessionDataTask?
    {
        if let parameters = parameters {
            url += "?" + stringFromParameters(parameters)
        }
        
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("TOKEN") as? String{
            self.token = savedToken.stringByRemovingPercentEncoding
        }
        
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        guard let nsUrl = NSURL(string: url) else {
            doNext(handler(HTTPResult.init(error: ServiceError.InvalidURL)))
            return nil
        }
        
        let request = NSMutableURLRequest(URL: nsUrl, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: timeout)
        request.HTTPMethod = method.rawValue
        request.HTTPBody = body
        
        headers.forEach { (key, value) -> () in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        print("Request: \(request.URL)")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.processResponse(data, response: response, error: error, handler: handler)
        }
        
        task.resume()
        return task
    }
    
    private func processResponse(data: NSData?, response: NSURLResponse?, error: NSError?, handler: (HTTPResult<AnyObject?>) -> ()) {
        if let error = error {
            // Probably need to pass response and data here,
            // or use them to generate more specific errors
            handler(HTTPResult(error: error))
            return
        }
        
        guard let response = response as? NSHTTPURLResponse else {
            let error = ServiceError.UnknownResponseType
            handler(HTTPResult(error: error))
            return
        }
        
        switch response.statusCode {
        case (200 ..< 300):
            guard let jsonData = data where jsonData.length > 0 else {
                handler(.Success(nil))
                return
            }
            
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
                handler(.Success(jsonObject))
            } catch {
                print("Error parsing JSON")
                let error = ServiceError.JSONParseError
                handler(.Error(error, data: nil))
            }
            
        case 401:
            self.invalidateToken()
            NSNotificationCenter.defaultCenter().postNotificationName("login", object: nil)
            handler(HTTPResult(error: ServiceError.InvalidToken))
            
        default:
            if let jsonData = data {
                do {
                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions())
                    let error = ServiceError.StatusCode(response.statusCode)
                    handler(.Error(error, data: jsonObject))
                } catch {
                    print("Error parsing JSON")
                    let error = ServiceError.JSONParseError
                    handler(.Error(error, data: nil))
                }
            }
            let error = ServiceError.UnknownStatusCode(response.statusCode)
            handler(HTTPResult(error: error))
        }
    }
    
    
    @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        print("didReceiveChallenge")
        
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
    }
    
    func invalidateToken(){
        self.token = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey("TOKEN")
    }
}

extension ClickeyServiceURLSession: ClickeyService {
    
    func authenticate(username: String, password:String, handler: (HTTPResult<Void>) -> ()) {
        invalidateToken()
        
        let headers = [
            "authorization": "Basic Y2xpY2tleS1hcHA6YXBwLWFjY2Vzcw==",
        ]
        
        let parameters: HTTPParametersType = [
            "username": username,
            "password": password,
            "grant_type": "password",
        ]
        
        request(.Post,
            url: oAuthTokenURL,
            parameters: parameters,
            headers: headers) { result in
                switch result {
                case let .Error(error, _):
                    let errorMessage = ["errorTitle": "Login fout", "errorMessage": "Voer een geldige gebruikersnaam en wachtwoord in."]
                    self.globalErrorHandler?(error, responseObject: errorMessage)
                    handler(HTTPResult<Void>.Error(error, data: errorMessage))
                case let .Success(object):
                    if let dict = object as? Dictionary<String, AnyObject>,
                        token =  dict["access_token"] as? String
                    {
                        NSUserDefaults.standardUserDefaults().setValue(token.urlEscaped, forKey: "TOKEN")
                        self.token = token
                        handler(.Success())
                    } else {
                        let error = ServiceError.NoTokenReturned
                        self.globalErrorHandler?(error, responseObject: nil)
                        handler(HTTPResult(error: error))
                    }
                }
        }
        
    }
    
    func logout(handler: (HTTPResult<Void>) -> ()){
        let headers = ["content-type": "application/x-www-form-urlencoded"]
        if let token = self.token{
            request(HTTPMethod.Delete,
                url: logoutURL + token,
                headers: headers) { result in
                    switch result {
                    case let .Error(error, data):
                        self.globalErrorHandler?(error, responseObject: data)
                        handler(.Error(error, data: data))
                    case .Success:
                        self.token = nil
                        handler(.Success())
                    }
            }
        }
    }
    
    func validate(bodyText: String, url: String, handler: (HTTPResult<Bool>) -> ()) {
        let headers = ["content-type": "application/x-www-form-urlencoded"]

        request(.Post,
            url: url,
            headers: headers,
            body: bodyText.dataUsingEncoding(NSUTF8StringEncoding)) { result in
            switch result {
            case let .Error(error, data):
                self.globalErrorHandler?(error, responseObject: data)
                handler(.Error(error, data: data))
            case let .Success(object):
                if let dict = object as? Dictionary<String, AnyObject>,
                    isValid =  dict["valid"] as? Bool
                {
                    handler(.Success(isValid))
                } else {
                    handler(HTTPResult(error: ServiceError.Invalid))
                }
            }
        }
    }
    
    func verifyUserName(userName:String, handler: (HTTPResult<Bool>) -> ()) {
        validate("username=\(userName)", url: userNameVerificationURL, handler: handler)
    }
    
    func verifyEmail(email:String, handler: (HTTPResult<Bool>) -> ()) {
        validate("emailAddress=\(email)", url: emailVerificationURL, handler: handler)
    }
    
    func verifyPassword(password:String, handler: (HTTPResult<Bool>) -> ()) {
        validate("password=\(password)", url: passwordVerificationURL, handler: handler)
    }
    
    func startBLE(id:Int, handler: (HTTPResult<Void>) -> ()) {
        request(.Post, url: startBLEURL(id), handler: { result in
            switch result {
            case let .Error(error, data):
                self.globalErrorHandler?(error, responseObject: data)
                handler(.Error(error, data: data))
            default: handler(.Success())
            }
        })
    }
    
    func stopBLE(id:Int, handler: (HTTPResult<Void>) -> ()) {
        request(.Post, url: stopBLEURL(id), handler: { result in
            switch result {
            case let .Error(error, data):
                self.globalErrorHandler?(error, responseObject: data)
                handler(.Error(error, data: data))
            default: handler(.Success())
            }
        })
    }
    
    func getLocation(id:Int, handler: (HTTPResult<(location: CLLocation, requestDate: NSDate, historical: Bool)>) -> ()) {
        request(.Post, url: locationURL(id), handler: { result in
            if case let .Error(error, data) = result {
                self.globalErrorHandler?(error, responseObject: data)
                handler(.Error(error, data: data))
                return
            }
            
            guard
                let dict = result.object as? [String: AnyObject],
                let latitude = dict["latitude"] as? Double,
                let longitude = dict["longitude"] as? Double,
                let requestTime = dict["requestTime"] as? String,
                let requestDate = NSDate.fromClickeyServer(requestTime),
                let historical = dict["historical"] as? Bool
                else
            {
                handler(.Error(ServiceError.JSONParseError, data: result.object ?? nil))
                return
            }
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            handler(.Success((location: location, requestDate: requestDate, historical: historical)))
        })
    }
    
    func getClickeys(handler: (HTTPResult<[ClickeyServerModel]>) -> ()) {
        request(.Get, url: clickeyListURL, handler: { result in
            switch result {
            case let .Error(error, data):
                self.globalErrorHandler?(error, responseObject: data)
                handler(.Error(error, data: data))
            case let .Success(object):
                guard let objects = object as? [[String: AnyObject]] else {
                    handler(HTTPResult(error: ServiceError.JSONParseError))
                    return
                }
                
                let clickeyList = objects
                    .flatMap { dict in ClickeyServerModel.parse(dict) }
                    .sort { $0.id < $1.id }
                
                handler(.Success(clickeyList))
            }
        })
    }
    
    func registerUser(username:String, password:String, email:String, handler: (HTTPResult<Void>) -> ()) {
        let headers = [
            "content-type": "application/json",
            "Accept": "application/json"
        ]
        
        let bodyObject = [
            "username": username,
            "password": password,
            "mailAddress": email,
        ]
        
        let body = try! NSJSONSerialization.dataWithJSONObject(bodyObject , options: NSJSONWritingOptions(rawValue: 0))
        
        request(.Post,
            url: registerURL,
            body: body,
            headers: headers,
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                default: handler(.Success())
                }
        })
    }
    
    func getAllSubscription(handler: (HTTPResult<Void>) -> ()) {
        request(.Get,
            url: subscriptionURL,
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                default: handler(.Success())
                }
        })
    }
    
    func getClickeySubscription(id: Int, handler: (HTTPResult<NSDictionary>) -> ()) {
        request(.Get,
            url: clickeySubscriptionURL + String(id),
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                case let .Success(object):
                    if let object = object as? NSDictionary {
                        handler(.Success(object))
                    } else {
                        handler(.Error(ServiceError.JSONParseError, data: object))
                    }
                }
        })
    }
    
    func getAllSubscriptionSchemes(handler: (HTTPResult<Void>) -> ()){
        request(.Get,
            url: subscriptionSchemeURL,
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                default: handler(.Success())
                }
        })
    }
    
    func getAllPaidSubscriptionSchemes(handler: (HTTPResult<[AnyObject]>) -> ()){
        request(HTTPMethod.Get,
            url: subscriptionPaidSchemeURL,
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                case let .Success(object):
                    if let object = object as? [AnyObject] {
                        handler(.Success(object))
                    } else {
                        handler(HTTPResult(error: ServiceError.JSONParseError))
                    }
                }
        })
    }
    
    func createSubcription(schemeID:Int, clickeyID:Int, handler: (HTTPResult<Void>) -> ()) {
        let headers = [
            "content-type": "application/json",
            "Accept": "application/json"
        ]
        
        let bodyObject = [
            "subscriptionSchemeId": String(schemeID),
            "userClickeyId": String(clickeyID)
        ]

        let body = try! NSJSONSerialization.dataWithJSONObject(bodyObject , options: NSJSONWritingOptions(rawValue: 0))
        
        request(.Post,
            url: createSubscriptionURL,
            body: body,
            headers: headers,
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                default: handler(.Success())
                }
        })
    }
    
    func cancelSubcription(id: Int, handler: (HTTPResult<Void>) -> ()) {
        request(.Post,
            url: cancelSubscriptionURL + String(id),
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                default: handler(.Success())
                }
        })
    }
    
    func registerForNotifications(deviceToken:String, handler: (HTTPResult<Void>) -> ()){
        if let uuidString = UIDevice.currentDevice().identifierForVendor?.UUIDString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()){
            print(uuidString)
            request(.Post,
                url: notificationURL(deviceToken, uuid: uuidString),
                handler: { result in
                    switch result {
                    case let .Error(error, data):
                        self.globalErrorHandler?(error, responseObject: data)
                        handler(.Error(error, data: data))
                    default: handler(.Success())
                    }
            })
        }
    }
    
    func registerClickey(image:UIImage?=nil, clickeyUuid:String, name:String, description:String, icon:String, handler: (HTTPResult<Void>) -> ()){
        let headers = [
            "content-type": "application/json",
            "Accept": "application/json"
        ]

        var bodyObject = [
            "clickeyUuid": clickeyUuid,
            "name": name,
            "description": description,
            "icon": icon
        ]
        
        if let  image = image,
                imageData = UIImagePNGRepresentation(image)
        {
            let imageDataBase64 = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            bodyObject["imageData"] = imageDataBase64
            bodyObject["imageExtension"] = "png"
        }
        
        let body = try! NSJSONSerialization.dataWithJSONObject(bodyObject , options: NSJSONWritingOptions(rawValue: 0))
        
        request(.Post,
            url: registerClickeyURL,
            body: body,
            headers: headers,
            handler: { result in
                switch result {
                case let .Error(error, data):
                    self.globalErrorHandler?(error, responseObject: data)
                    handler(.Error(error, data: data))
                default: handler(.Success())
                }
        })
    }
    
}
