//
//  ClickeyService.swift
//  Clickey
//
//  Created by Berik Visschers on 07-29.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import MapKit

enum HTTPResult<T> {
    case Success(T)
    case Error(ErrorType, data:AnyObject?)
    
    init(error: ErrorType, data: AnyObject? = nil) {
        self = .Error(error, data: data)
    }
    
    var isSuccess: Bool {
        switch self {
        case .Success: return true
        case .Error: return false
        }
    }
    
    var error: ErrorType? {
        switch self {
        case let .Error(error, data: _): return error
        default: return nil
        }
    }
    
    var object: T? {
        switch self {
        case let .Success(object): return object
        default: return nil
        }
    }
}

enum HTTPMethod: String {
    case Get = "GET"
    case Post = "POST"
    case Delete = "DELETE"
    case Put = "Put"
}

enum HTTPBody: String {
    case JSON = "JSON"
    case HTTPParameters = "HTTPParameters"
}

typealias HTTPParametersType = Dictionary<String, HTTPParameterValue>

private let urlSession = ClickeyServiceURLSession()
private let mock = ClickeyServiceMock()

protocol ClickeyServiceConsumer {
    var service: ClickeyService { get }
}

extension ClickeyServiceConsumer {
    var service: ClickeyService {
        if Constants.simulateServer {
            return mock
        } else {
            return urlSession
        }
    }
}

protocol ClickeyService: class {
    var globalErrorHandler: ((ErrorType, responseObject: AnyObject?) -> ())? { get set }
    
    func authenticate(username: String, password:String, handler: (HTTPResult<Void>) -> ())
    func logout(handler: (HTTPResult<Void>) -> ())
    
    func startBLE(id:Int, handler: (HTTPResult<Void>) -> ())
    func stopBLE(id:Int, handler: (HTTPResult<Void>) -> ())
    
    func getLocation(id:Int, handler: (HTTPResult<(location: CLLocation, requestDate: NSDate, historical: Bool)>) -> ())
    func getClickeys(handler: (HTTPResult<[ClickeyServerModel]>) -> ())
    
    func verifyUserName(userName:String, handler: (HTTPResult<Bool>) -> ())
    func verifyEmail(email:String, handler: (HTTPResult<Bool>) -> ())
    func verifyPassword(password:String, handler: (HTTPResult<Bool>) -> ())
    
    func registerUser(username:String, password:String, email:String, handler: (HTTPResult<Void>) -> ())
    func getAllSubscription(handler: (HTTPResult<Void>) -> ())
    func getAllSubscriptionSchemes(handler: (HTTPResult<Void>) -> ())
    func getAllPaidSubscriptionSchemes(handler: (HTTPResult<[AnyObject]>) -> ())
    func getClickeySubscription(id:Int, handler: (HTTPResult<NSDictionary>) -> ())
    func cancelSubcription(id:Int, handler: (HTTPResult<Void>) -> ())
    func createSubcription(schemeID:Int, clickeyID:Int, handler: (HTTPResult<Void>) -> ())
    func registerClickey(image:UIImage?, clickeyUuid:String, name:String, description:String, icon:String, handler: (HTTPResult<Void>) -> ())
    func registerForNotifications(deviceToken:String, handler: (HTTPResult<Void>) -> ())
}


enum ServiceError: ErrorType {
    case Invalid
    case InvalidURL
    case InvalidToken
    case NoTokenReturned
    case LoginFailed
    case UnknownResponseType
    case Unreachable
    case UnknownStatusCode(Int)
    case StatusCode(Int)
    case JSONParseError
}

func doNext(@autoclosure(escaping) block: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), block)
}

func afterDelay(delay:Double = 0.4, block: () -> ()) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue(), block)
}


protocol HTTPParameterValue {
    var urlEscaped: String { get }
}

extension String: HTTPParameterValue {
    var urlEscaped: String {
        if let escaped = self.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()){
            return escaped
        }else{
            return self
        }
    }
}

extension CustomStringConvertible where Self: HTTPParameterValue {
    var urlEscaped: String {return description.urlEscaped}
}

