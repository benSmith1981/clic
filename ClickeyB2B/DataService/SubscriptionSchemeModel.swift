//
//  SubscriptionSchemeModel.swift
//  Clickey
//
//  Created by Sem Shafiq on 09/09/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import UIKit

class SubscriptionSchemeModel: NSObject {
    let duration:NSNumber
    let id:Int
    let price:NSNumber
    let status:String
    
    init(id:Int, duration:NSNumber, price:NSNumber, status:String){
        self.id = id
        self.duration = duration
        self.price = price
        self.status = status
    }
    
    static func parse(subscriptionScheme:NSDictionary) -> SubscriptionSchemeModel?{
        if let duration = subscriptionScheme["duration"] as? NSNumber,
            let schemeid = subscriptionScheme["id"] as? Int,
            let price = subscriptionScheme["price"] as? NSNumber,
            let status = subscriptionScheme["status"] as? String
        {
            return SubscriptionSchemeModel(id: schemeid, duration: duration, price: price, status: status)
        }
        return nil
    }
}
