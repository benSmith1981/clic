//
//  PeripheralManager.swift
//  Clickey
//
//  Created by Sem Shafiq on 03/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class PeripheralManager: NSObject, CBPeripheralDelegate{
    
    static let sharedInstance = PeripheralManager()
    
    var connectedDevice: ClickeyModel!
    var alertLevel = 0
    override init() {
        super.init()
    }
    
    func startDiscoveringServices(){
        connectedDevice.characteristicValues.updateValue(connectedDevice.peripheral.identifier.UUIDString, forKey: "UUID:")
        connectedDevice.characteristicValues.updateValue("Unpaired", forKey: "Status:")
        connectedDevice.peripheral.discoverServices(nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("toggleBuzzer"), name: "toggleBuzzer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("startBuzzer"), name: "startBuzzer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopBuzzer"), name: "stopBuzzer", object: nil)
    }
    
    func unregisterNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "toggleBuzzer", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "startBuzzer", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "stopBuzzer", object: nil)
    }
    
    //MARK: - CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if let actualError = error{
            print("didDiscoverServices Error: \(actualError.debugDescription)")
        }
        else {
            peripheral.readRSSI()
            for service in peripheral.services as [CBService]!{
                print("didDiscoverServices \(service.UUID.UUIDString)")
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?) {
        if error != nil {
            print("didReadRSSI Error: \(error.debugDescription)")
            return
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("didReadRSSI", object: nil, userInfo: ["RSSI": RSSI])
        print("didReadRSSI \(RSSI)")
        connectedDevice.updateRSSI(RSSI.doubleValue)
        connectedDevice.characteristicValues.updateValue(String(RSSI.doubleValue), forKey: "RSSI")
        NSNotificationCenter.defaultCenter().postNotificationName("valueRetrieved", object: nil)
        afterDelay(0.2){
            self.connectedDevice.peripheral.readRSSI()
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if let actualError = error{
            print("didDiscoverCharacteristicsForService Error: \(actualError.debugDescription)")
        }
        else {
            peripheral.delegate = self
            switch service.UUID.UUIDString{
            case Constants.SERVICES.GAP_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.DEVICE_NAME.rawValue:
                        print("Found a DEVICE_NAME Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_NAME.rawValue)
                    case Constants.CHARACTERISTICS.DEVICE_APPEARANCE.rawValue:
                        print("Found a DEVICE_APPEARANCE Characteristic")
                    case Constants.CHARACTERISTICS.DEVICE_PREF_CONN_PARAMS.rawValue:
                        print("Found a DEVICE_PREF_CONN_PARAMS Characteristic")
                        
                    default:
                        print("default-characteristic: " + characteristic.UUID.UUIDString)
                    }
                    
                }
            case Constants.SERVICES.GATT_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.SERVICE_CHANGED.rawValue:
                        print("Found a SERVICE_CHANGED Characteristic")
                    default:
                        print("default-characteristic: " + characteristic.UUID.UUIDString)
                    }
                    
                }
            case Constants.SERVICES.IMM_ALERT_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.ALERT_LEVEL.rawValue:
                        print("Found a IMM_ALERT_LEVEL Characteristic ")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.ALERT_LEVEL.rawValue)
                    default:
                        print("default-characteristic: " + characteristic.UUID.UUIDString)
                    }
                    
                }
            case Constants.SERVICES.TX_POWER_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.TX_POWER_LEVEL.rawValue:
                        print("Found a TX_POWER_LEVEL Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.TX_POWER_LEVEL.rawValue)
                    default:
                        print("default-characteristic: " + characteristic.UUID.UUIDString)
                    }
                    
                }
            case Constants.SERVICES.DEVICE_INFO_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.DEVICE_INFO_MANUFACTURER_NAME.rawValue:
                        print("Found a DEVICE_INFO_MANUFACTURER_NAME Characteristic)")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_MANUFACTURER_NAME.rawValue)
                    case Constants.CHARACTERISTICS.DEVICE_INFO_MODEL_NUMBER.rawValue:
                        print("Found a DEVICE_INFO_MODEL_NUMBER Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_MODEL_NUMBER.rawValue)
                        
                    case Constants.CHARACTERISTICS.DEVICE_INFO_SERIAL_NUMBER.rawValue:
                        print("Found a DEVICE_INFO_SERIAL_NUMBER Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_SERIAL_NUMBER.rawValue)
                        
                    case Constants.CHARACTERISTICS.DEVICE_INFO_HARDWARE_REVISION.rawValue:
                        print("Found a DEVICE_INFO_HARDWARE_REVISION Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_HARDWARE_REVISION.rawValue)
                        
                    case Constants.CHARACTERISTICS.DEVICE_INFO_FIRMWARE_REVISION.rawValue:
                        print("Found a DEVICE_INFO_FIRMWARE_REVISION Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_FIRMWARE_REVISION.rawValue)
                        //showFirmwareNumber(readValue(characteristic))
                        
                    case Constants.CHARACTERISTICS.DEVICE_INFO_SOFTWARE_REVISION.rawValue:
                        print("Found a DEVICE_INFO_SOFTWARE_REVISION Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_SOFTWARE_REVISION.rawValue)
                        
                    case Constants.CHARACTERISTICS.DEVICE_INFO_SYSTEM_ID.rawValue:
                        print("Found a DEVICE_INFO_SYSTEM_ID Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_SYSTEM_ID.rawValue)
                        
                    case Constants.CHARACTERISTICS.DEVICE_INFO_PNP_ID.rawValue:
                        print("Found a DEVICE_INFO_PNP_ID Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DEVICE_INFO_PNP_ID.rawValue)
                        startReadingCharacteristics()
                    default:
                        print("unknown-characteristic: " + characteristic.UUID.UUIDString)
                    }
                }
            case Constants.SERVICES.LINK_LOSS_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.ALERT_LEVEL.rawValue:
                        print("Found a LINK_LOSS_ALERT_LEVEL Characteristic")
                    default:
                        print("unknown-characteristic: " + characteristic.UUID.UUIDString)
                    }
                }
            case Constants.SERVICES.RSSI.rawValue:
                for characteristic in service.characteristics!{
                    print("RSSI characteristic: \(characteristic.UUID.UUIDString)")
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.RSSI.rawValue:
                        print("Found a RSSI_SERVICE Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.RSSI.rawValue)
                    default:
                        print("unknown-characteristic: " + characteristic.UUID.UUIDString)
                    }
                }
            case Constants.SERVICES.DATA.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.DATA_PIN.rawValue:
                        print("Found a DATA_PIN Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DATA_PIN.rawValue)
                    case Constants.CHARACTERISTICS.DATA_LORA.rawValue:
                        print("Found a DATA_LORA Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.DATA_LORA.rawValue)
                    default:
                        print("unknown-characteristic: " + characteristic.UUID.UUIDString)
                    }
                }
            case Constants.SERVICES.BATTERY_SERVICE.rawValue:
                for characteristic in service.characteristics!{
                    switch characteristic.UUID.UUIDString{
                    case Constants.CHARACTERISTICS.BATTERY_LEVEL.rawValue:
                        print("Found a BATT_LEVEL Characteristic")
                        connectedDevice.characteristics.updateValue(characteristic, forKey: Constants.CHARACTERISTICS.BATTERY_LEVEL.rawValue)
                    default:
                        print("unknown-characteristic: " + characteristic.UUID.UUIDString)
                    }
                    
                }
            default:
                print("unknown-service_UUID: " + service.UUID.UUIDString)
            }
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("didUpdateValueForCharacteristic: \(characteristic.UUID.UUIDString) Error:\(error.debugDescription)")
            if characteristic.UUID.UUIDString != Constants.CHARACTERISTICS.DATA_PIN.rawValue{
                //popView(self)
            }
        }
        print("didUpdateValueForCharacteristic: \(characteristic.UUID.UUIDString)")
        guard let _ = characteristic.value else{
            return
        }
        var value = NSString(string: "")
        switch characteristic.UUID.UUIDString{
        case Constants.CHARACTERISTICS.RSSI.rawValue:
            print("CHARACTERISTICS.RSSI: \(readValue(characteristic, isString: false))")
            connectedDevice.characteristicValues.updateValue("Paired", forKey: "Status:")
            NSNotificationCenter.defaultCenter().postNotificationName("clickeyPaired", object: nil)
            //pairingStatus.text = "Status: Paired"
            //if connectedDevice.characteristics[CHARACTERISTICS.ALERT_LEVEL.rawValue] != nil {
            //    showAlertLevel()
            //}
            //if connectedDevice.characteristics[CHARACTERISTICS.DATA_PIN.rawValue] != nil {
            //    Enter_Pin_Button.hidden = false
            //}
        case Constants.CHARACTERISTICS.DATA_LORA.rawValue:
            value = readValue(characteristic, isString: false)
            //print("DATA_LORA \(value)")
            connectedDevice.characteristicValues.updateValue(value as String, forKey: "Lora ID:")
        case Constants.CHARACTERISTICS.TX_POWER_LEVEL.rawValue:
            value = readValue(characteristic, isString: false)
            //print("TX_POWER_LEVEL \(value)")
            connectedDevice.characteristicValues.updateValue(readValue(characteristic, isString: false) as String, forKey: "Tx Power:")
        case Constants.CHARACTERISTICS.BATTERY_LEVEL.rawValue:
            value = readValue(characteristic, isString: false)
            //print("BATTERY_LEVEL \(value)")
            connectedDevice.characteristicValues.updateValue("\(value)%", forKey: "Battery:")
        case Constants.CHARACTERISTICS.DEVICE_INFO_MANUFACTURER_NAME.rawValue:
            value = readValue(characteristic)
            //print("DEVICE_INFO_MANUFACTURER_NAME: \(value)")
            connectedDevice.characteristicValues.updateValue("\(value)", forKey: "Manufacturer:")
        case Constants.CHARACTERISTICS.DEVICE_INFO_MODEL_NUMBER.rawValue:
            value = readValue(characteristic)
            //print("DEVICE_INFO_MODEL_NUMBER \(value)")
            connectedDevice.characteristicValues.updateValue("\(value)", forKey: "Model No.:")
        case Constants.CHARACTERISTICS.DEVICE_INFO_SERIAL_NUMBER.rawValue:
            value = readValue(characteristic)
            //print("DEVICE_INFO_SERIAL_NUMBER \(value)")
            connectedDevice.characteristicValues.updateValue("\(value)", forKey: "Serial No.:")
        case Constants.CHARACTERISTICS.DEVICE_INFO_FIRMWARE_REVISION.rawValue:
            value = readValue(characteristic)
            //print("DEVICE_INFO_FIRMWARE_REVISION \(value)")
            connectedDevice.characteristicValues.updateValue("\(value)", forKey: "Firmware:")
        case Constants.CHARACTERISTICS.DEVICE_INFO_SOFTWARE_REVISION.rawValue:
            value = readValue(characteristic)
            //print("DEVICE_INFO_SOFTWARE_REVISION \(value)")
            connectedDevice.characteristicValues.updateValue("\(value)", forKey: "Software")
            
        case Constants.CHARACTERISTICS.DEVICE_INFO_SYSTEM_ID.rawValue:
            value = readValue(characteristic)
            print("DEVICE_INFO_SYSTEM_ID: \(value)")
        default:
            value = readValue(characteristic)
            //print("didUpdateValueForCharacteristic unknonw: \(characteristic.UUID.UUIDString) \(readValue(characteristic))")
            /*if value.length > 0 {
                connectedDevice.characteristicValues.updateValue("\(value)", forKey: "\(characteristic.UUID.UUIDString):")
            }*/
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("valueRetrieved", object: nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil{
            print("didUpdateNotificationStateForCharacteristic: \(error.debugDescription)")
        }
        
        print("didUpdateNotificationStateForCharacteristic: \(characteristic.UUID)")
        
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil{
            print("didWriteValueForCharacteristic: Error: \(error.debugDescription) characteristic:\(characteristic.UUID.UUIDString)")
        }
        print("didWriteValueForCharacteristic: \(characteristic.UUID.UUIDString) \(readValue(characteristic, isString: false))")
        if characteristic.UUID.UUIDString == Constants.CHARACTERISTICS.DATA_PIN.rawValue{
            NSNotificationCenter.defaultCenter().postNotificationName("pinAccepted", object: nil)
        }
    }
    
    // MARK: -
    func startReadingCharacteristics(){
        print("startReadingCharacteristics:")
        let peripheral = connectedDevice.peripheral
        for characteristicKey in connectedDevice.characteristics.keys{
            guard let characteristic = connectedDevice.characteristics[characteristicKey] else{
                print("startReadingCharacteristics: invalid characteristic")
                return
            }
            switch characteristicKey{
            case Constants.CHARACTERISTICS.RSSI.rawValue:
                print("startReadingCharacteristics RSSI")
                peripheral.readValueForCharacteristic(characteristic)
                //peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            case Constants.CHARACTERISTICS.DATA_LORA.rawValue:
                print("startReadingCharacteristics DATA_LORA")
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.TX_POWER_LEVEL.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.BATTERY_LEVEL.rawValue:
                print("Battery service is inaccessible in POC 3 device")
                peripheral.readValueForCharacteristic(characteristic)
                //peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_MANUFACTURER_NAME.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_MODEL_NUMBER.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_SERIAL_NUMBER.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_HARDWARE_REVISION.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_FIRMWARE_REVISION.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_SOFTWARE_REVISION.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DEVICE_INFO_SYSTEM_ID.rawValue:
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.ALERT_LEVEL.rawValue:
                print("ALERT_LEVEL")
            case Constants.CHARACTERISTICS.DEVICE_INFO_PNP_ID.rawValue:
                print("DEVICE_INFO_PNP_ID")
                peripheral.readValueForCharacteristic(characteristic)
            case Constants.CHARACTERISTICS.DATA_PIN.rawValue:
                print("Pin code service might use to authenticate device communication")
            default:
                print("startReadingCharacteristics unknonw: \(characteristic.UUID.UUIDString)")
                peripheral.readValueForCharacteristic(characteristic)
                
            }
        }
    }
    
    func writePinCode(inputString:String){
        if let dataPinCharacteristic = connectedDevice.characteristics[Constants.CHARACTERISTICS.DATA_PIN.rawValue]{
            var params = inputString.characters.map{Int(String($0))}
            let data = NSData(bytes: &params, length: params.count)
            self.connectedDevice.peripheral.writeValue(data, forCharacteristic: dataPinCharacteristic, type: self.getWriteType(dataPinCharacteristic))
        }
    }
    
    func readValue(characteristic: CBCharacteristic, isString:Bool = true) -> NSString {
        var value = NSString()
        guard let charValue = characteristic.value else{
            return value
        }
        if(isString){
            let stringValueFromData = NSString(data: charValue, encoding: NSUTF8StringEncoding)
            guard let stringValue = stringValueFromData else{
                var intValue: NSInteger = 0
                charValue.getBytes(&intValue, length: sizeof(NSInteger))
                value = NSString(string: String(intValue))
                return value
            }
            value = stringValue
            
        }else{
            var intValue: NSInteger = 0
            charValue.getBytes(&intValue, length: sizeof(NSInteger))
            value = NSString(string: String(intValue))
        }
        return value
    }
    
    func toggleBuzzer(){
        var parameter:[UInt8]
        
        if alertLevel == 0 {
            parameter = [0x02]
            alertLevel = 2
        }else{
            parameter = [0x00]
            alertLevel = 0
        }
        
        setBuzzer(parameter)
    }
    
    func startBuzzer(){
        setBuzzer([0x02])
    }
    
    func stopBuzzer(){
        setBuzzer([0x00])
    }
    
    func setBuzzer(value:[UInt8]){
        var parameter:[UInt8] = value
        let data = NSData(bytes: &parameter, length: parameter.count)
        if let alertCharacteristic = connectedDevice.characteristics[Constants.CHARACTERISTICS.ALERT_LEVEL.rawValue]{
            connectedDevice.peripheral.writeValue(data, forCharacteristic: alertCharacteristic, type: getWriteType(alertCharacteristic))
        }
    }
    
    func getWriteType(characteristic:CBCharacteristic) -> CBCharacteristicWriteType{
        var writeType:CBCharacteristicWriteType = CBCharacteristicWriteType.WithResponse
        if (characteristic.properties.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue) != 0 {
            writeType = CBCharacteristicWriteType.WithoutResponse
        }else if ((characteristic.properties.rawValue & CBCharacteristicProperties.Write.rawValue) != 0){
            
            writeType = CBCharacteristicWriteType.WithResponse
        }
        return writeType
    }
}
