//
//  ClickeyServerModel.swift
//  Clickey
//
//  Created by Sem Shafiq on 10/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import UIKit
import MapKit

enum ClickeyStatus:String{
    case NEW = "NEW"
    case ACTIVE = "ACTIVE"
    case INACTIVE = "INACTIVE"
}

class ClickeyServerModel: NSObject {

    var name: String
    var desc: String
    var uuid: String
    var imageUrl: String?
    var icon: String
    var eui: String
    var id: Int
    var userAccountId: Int
    var deleted:Bool
    var status:ClickeyStatus
    var location: CLLocation!
    var locationRequestTime: NSDate!
    var isHistoricalLocation: Bool!

    init(id:Int, name:String, desc:String, uuid:String, eui:String, icon:String, deleted:Bool, status:ClickeyStatus, userAccountId:Int){
        self.id = id
        self.name = name
        self.desc = desc
        self.uuid = uuid
        self.eui = eui
        self.icon = icon
        self.deleted = deleted
        self.status = status
        self.userAccountId = userAccountId
    }
    
    class func parse(json:NSDictionary) -> ClickeyServerModel?{
        if let clickey = json["clickey"] as? NSDictionary,
            name = (json["name"] is NSNull) ? "Clickey" : (json["name"] as? String),
            desc = (json["description"] is NSNull) ? "" : (json["description"] as? String){
//            icon = json["icon"] as? String,
//            isDeleted = json["isDeleted"] as? Bool,
//            userAccountId = json["userAccountId"] as? Int ,
//            status =  json["status"] as? String{
            print("clickey" + (name as! String))

            if let clickeyID = clickey["id"] as? Int{
//                clickeyUUID = clickey["uuid"] as? String,
//                clickeyEUI = clickey["eui"] as? String{
                let model = ClickeyServerModel(id:clickeyID,
                                               name: name,
                                               desc: desc,
                                               uuid: "",
                                               eui: "",
                                               icon: "",
                                               deleted:false,
                                               status: ClickeyStatus.ACTIVE,
                                               userAccountId: 1)
                if let imageUrl = json["imageUrl"] as? String{
                    model.imageUrl = imageUrl
                }
                if let clickeyLatestState = json["clickeyLatestState"] as? NSDictionary,
//                    batteryStatus = clickeyLatestState["batteryNotificationStatus"] as? String,
                    latestMessages = clickeyLatestState["latestMessages"] as? NSDictionary{
  
                        var keys = latestMessages.allKeys as! [String]
                        var tempDate: NSDate! = nil
                        print("location" + model.name)
                        for key in keys {
                            if let message = latestMessages[key],
                                stringDate = message["receivedDate"] as? String {
                                let dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSZZZ"
                                if let aDate = dateFormatter.dateFromString(stringDate) {
                                    print(aDate)
//                                    if aDate.isGreaterThanDate(tempDate){
//                                        if let latitude = message["latitude"] as? Double,
//                                            longitude = message["longitude"] as? Double {
//                                                var longitudeNew = latitude
//                                                var latitudeNew = longitude
//                                            
//                                        }
//                                    }
//                            
                                }
                                if let latitude = message["latitude"] as? Double,
                                    longitude = message["longitude"] as? Double {
                                    model.location = CLLocation.init(latitude: latitude, longitude: longitude)
                                }
                            }
                        
                        }

                }
                
                return model
            }

        }
        return nil
    }
    
    func updateLocation(location:CLLocation, time:NSDate, historical:Bool){
        self.location = location
        self.locationRequestTime = time
        self.isHistoricalLocation = historical
    }
}
