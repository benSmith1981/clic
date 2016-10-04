//
//  ClickeyModel.swift
//  Clickey
//
//  Created by Sem Shafiq on 10/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import UIKit
import CoreBluetooth

class ClickeyModel: NSObject {
    var id: Int
    var name: String
    let peripheral: CBPeripheral
    let identifier:NSUUID
    var RSSI: Double = 0.0
    var instantDistance: Double = 10.0
    var distance: Double = 1.0
    
    var characteristics = [String: CBCharacteristic]()
    
    var characteristicValues = [String: String]()
    
    init(id:Int, peripheral: CBPeripheral) {
        var deviceName = "Unknown"
        if let peripheralName = peripheral.name {
            deviceName = peripheralName
        }
        self.id = id
        self.name = deviceName
        self.identifier = peripheral.identifier
        self.peripheral = peripheral
    }
    
    func updateRSSI(RSSI: Double) {
        // RSSI (dBm) = -10n log10(d) + A
        // 0 = -10n log10(d) + A - dBm
        // 10n log10(d) = A - dBm
        // log10(d) = (A - dBm) / 10n
        // d = 10 ^ ((A - dBm) / 10n)
        self.RSSI = RSSI
        self.name = "\(self.name)   -   RSSI: \(RSSI)"
        let n = 2.1
        let txPower = -70.0
        instantDistance = pow(10.0, (txPower - RSSI) / (n * 10.0))
        distance = exponentialMovingAverage(distance, newValue: instantDistance, smoothing: 0.5)
        
        /*if state == .TooFar || state == .InRange {
        state = distance < 0.05 ? .InRange : .TooFar
        }*/
    }
    
    func exponentialMovingAverage(currentAverage: Double, newValue: Double, smoothing: Double) -> Double {
        return (1 - smoothing) * newValue + smoothing * currentAverage
    }
}
