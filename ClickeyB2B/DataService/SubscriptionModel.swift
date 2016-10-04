//
//  SubscriptionModel.swift
//  Clickey
//
//  Created by Sem Shafiq on 09/09/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import UIKit

class SubscriptionModel: NSObject {
    var startDate:NSDate
    var endDate:NSDate
    var id:Int
    var status:String
    var scheme:SubscriptionSchemeModel
    var clickey:ClickeyServerModel
    var cancellable:Bool
    init(id:Int, startDate:NSDate, endDate:NSDate, status:String, scheme:SubscriptionSchemeModel, clickey:ClickeyServerModel, cancellable:Bool){
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.scheme = scheme
        self.clickey = clickey
        self.cancellable = cancellable
    }
}

/*
selectedSubscription {
dateEnd = 1464739199000;
dateStart = 1433116800000;
id = 7;
status = ACTIVE;
subscriptionScheme =     {
    duration = 6M;
    id = 3;
    price = 15;
    status = ACTIVE;
    tenantId = 1;
    type = CONSUMER;
};
userClickey =     {
    clickey =         {
        deleted = 0;
        eui = C3D100003C000000;
        id = 1;
        status = NEW;
        tenantId = 1;
        uuid = "0F09C26B-14FD-6DA0-AA7B-414B77077371";
    };
    id = 1;
    imageUrl = "<null>";
    isDeleted = 0;
    name = "<null>";
    status = ACTIVE;
    userAccountId = 1;
};
}
*/
