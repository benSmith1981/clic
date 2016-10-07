//
//  ClickeyPayloadModel.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 07/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation

class ClickeyPayloadModel: NSObject {
    var temperature: String
    var batteryLevel: String
    
    init(temperature: String, batteryLevel: String){
        self.temperature = temperature
        self.batteryLevel = batteryLevel
    }
}