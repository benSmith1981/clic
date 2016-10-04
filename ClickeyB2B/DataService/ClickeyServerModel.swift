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
            name = json["name"],
            desc = json["description"],
            icon = json["icon"] as? String,
            isDeleted = json["isDeleted"] as? Bool,
            userAccountId = json["userAccountId"] as? Int,
            status =  json["status"] as? String{
            if let clickeyID = clickey["id"] as? Int,
                clickeyUUID = clickey["uuid"] as? String,
                clickeyEUI = clickey["eui"] as? String{
                    let model = ClickeyServerModel(id:clickeyID, name: (name is NSNull) ? "Clickey" : name as! String,
                        desc: (desc is NSNull) ? "" : desc as! String,
                        uuid: clickeyUUID,
                        eui: clickeyEUI,
                        icon: icon,
                        deleted:isDeleted, status: ClickeyStatus(rawValue: status)!,
                        userAccountId: userAccountId)
                    if let imageUrl = json["imageUrl"] as? String{
                        model.imageUrl = imageUrl
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