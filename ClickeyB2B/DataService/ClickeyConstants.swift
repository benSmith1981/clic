//
//  ClickeyConstants.swift
//  Clickey
//
//  Created by Berik Visschers on 07-29.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Constants {
    static let hockeyAppIdentifier = "2dc3c1482afed7a10ca98039b8d6549e"
    static let baseURL = "https://clickey-ci-env.elasticbeanstalk.com/"
    static let termsConditionURL = "http://invenit.nl/"
    static let fairUsagePolicyURL = "http://invenit.nl/"
    
    static let tintColor = "66ccff"
    static let clickeyFont = "Mobiquity-Custom-Font-v-01"
    static let fontAwesome = "FontAwesome"
    static let icomoonFont = "icomoon"
    
    static var simulateServer:  Bool { return NSProcessInfo().arguments.contains("-SimulateServer") }
    static var clearStorage:    Bool { return NSProcessInfo().arguments.contains("-ClearStorage") }
    
    //User & Password rules by Google https://support.google.com/a/answer/33386?hl=en
    static let inputMaxLength = 254
    static let userMaxLength = 30
    static let passwordMaxLength = 100
    static let emailMaxLength = 200
    static let userAllowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-.'"
    static let passwordAllowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-@%.#$!%&'()*+,/:;<>=?[]\\^`{}|~€"
    static let emailAllowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@.!#$%&'*+-/=?^_`{|}~"
    
    //Clickey Characteristic UUIDs
    enum CHARACTERISTICS: String {
        case DEVICE_NAME = "2A00"
        case DEVICE_APPEARANCE = "2A01"
        case DEVICE_PREF_CONN_PARAMS = "2A04"
        case SERVICE_CHANGED = "2A05"
        case ALERT_LEVEL = "2A06"
        case TX_POWER_LEVEL = "2A07"
        case DEVICE_INFO_MANUFACTURER_NAME = "2A29"
        case DEVICE_INFO_MODEL_NUMBER = "2A24"
        case DEVICE_INFO_SERIAL_NUMBER = "2A25"
        case DEVICE_INFO_HARDWARE_REVISION = "2A27"
        case DEVICE_INFO_FIRMWARE_REVISION = "2A26"
        case DEVICE_INFO_SOFTWARE_REVISION = "2A28"
        case DEVICE_INFO_SYSTEM_ID = "2A23"
        case DEVICE_INFO_PNP_ID = "2A50"
        case BATTERY_LEVEL = "2A19"
        case RSSI = "7CF58951-53A5-4082-B605-1887135295DA"
        case DATA_PIN = "18712101-9BE5-4231-8A11-82702076199A"
        case DATA_LORA = "18712102-9BE5-4231-8A11-82702076199A"
    }
    
    //Clickey Service UUIDs
    enum SERVICES: String {
        case GAP_SERVICE = "1800"
        case GATT_SERVICE = "1801"
        case IMM_ALERT_SERVICE = "1802"
        case LINK_LOSS_SERVICE = "1803"
        case TX_POWER_SERVICE = "1804"
        case DEVICE_INFO_SERVICE = "180A"
        case BATTERY_SERVICE = "180F"
        case RSSI = "7CF58950-53A5-4082-B605-1887135295DA"
        case DATA = "18712100-9BE5-4231-8A11-82702076199A"
    }
    
    static let CONNECTION_OPTIONS = [CBConnectPeripheralOptionNotifyOnConnectionKey: 1, CBConnectPeripheralOptionNotifyOnDisconnectionKey: 0, CBConnectPeripheralOptionNotifyOnNotificationKey: 1]
    static let SCAN_OPTIONS = [CBCentralManagerScanOptionAllowDuplicatesKey: 1]
    
    static let SERVICE_UUIDS:[CBUUID] = [CBUUID(string:SERVICES.GAP_SERVICE.rawValue), CBUUID(string:SERVICES.GATT_SERVICE.rawValue), CBUUID(string:SERVICES.IMM_ALERT_SERVICE.rawValue), CBUUID(string:SERVICES.LINK_LOSS_SERVICE.rawValue), CBUUID(string:SERVICES.TX_POWER_SERVICE.rawValue), CBUUID(string:SERVICES.DEVICE_INFO_SERVICE.rawValue), CBUUID(string:SERVICES.BATTERY_SERVICE.rawValue), CBUUID(string:SERVICES.RSSI.rawValue), CBUUID(string:SERVICES.DATA.rawValue)]
    
    static let ADVERTISED_UUIDS:[CBUUID] = [CBUUID(string:SERVICES.IMM_ALERT_SERVICE.rawValue), CBUUID(string:SERVICES.LINK_LOSS_SERVICE.rawValue), CBUUID(string:SERVICES.TX_POWER_SERVICE.rawValue)]
}


