//
//  SubscriptionParser.swift
//  Clickey
//
//  Created by Sem Shafiq on 09/09/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import UIKit

class SubscriptionParser:NSObject {
    class func parse(subscriptions:NSDictionary) -> [SubscriptionModel]{
        guard let subscriptionsList = (subscriptions["subscriptions"] as? Array<AnyObject>) else {
            print("Error parsing subscription json: \(subscriptions)")
            return []
        }
        
        return subscriptionsList.flatMap { subscriptionJson -> SubscriptionModel? in
            if  let subscription            = subscriptionJson["subscription"] as? NSDictionary,
                let cancellable             = subscriptionJson["cancellable"] as? Bool,
                let dateStartString         = subscription["dateStart"]     as? String,
                let dateEndString           = subscription["dateEnd"]       as? String,
                let dateStart               = NSDate.fromClickeyServer(dateStartString),
                let dateEnd                 = NSDate.fromClickeyServer(dateEndString),
                let id                      = subscription["id"] as? Int,
                let subscriptionStatus      = subscription["status"] as? String,
                let subscriptionScheme      = subscription["subscriptionScheme"] as? NSDictionary,
                let userClickey             = subscription["userClickey"] as? NSDictionary,
                let clickeyModel            = ClickeyServerModel.parse(userClickey),
                let scheme                  = SubscriptionSchemeModel.parse(subscriptionScheme) {
                    
                    return SubscriptionModel(
                        id: id,
                        startDate: dateStart,
                        endDate: dateEnd,
                        status: subscriptionStatus,
                        scheme: scheme,
                        clickey: clickeyModel,
                        cancellable: cancellable)
            } else {
                print("Error parsing subscription json: \(subscriptionJson)")
                return nil
            }
        }
    }
    
    class func parseSchemes(jsonList:[AnyObject]) -> [SubscriptionSchemeModel]{
        return jsonList.flatMap { json in
            guard let scheme = json as? NSDictionary else {
                print("Error parsing subscription json: \(json)")
                return nil
            }
            return scheme
        }
            .flatMap { scheme in
                return SubscriptionSchemeModel.parse(scheme)
        }
    }
}
