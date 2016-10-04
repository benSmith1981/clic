//
//  BluetoothManager.swift
//  Clickey
//
//  Created by Sem Shafiq on 03/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManager : NSObject, CBCentralManagerDelegate {
    
    private var centralManager:CBCentralManager!
    
    static let sharedInstance = BluetoothManager()
    
    var selectedClickey: ClickeyServerModel!
    var connectedDevice: ClickeyModel!
    
    var isScanning = false
    var isDeviceFound = false
    
    var scanTimeout = 60.0
    
    override init() {
        super.init()
    }
    
    func initialize(){
         centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state{
        case .PoweredOn:
            print("BLE powered On")
            self.startScan()
            afterDelay(scanTimeout){
                if self.isScanning{
                    self.stopScan()
                    if self.connectedDevice == nil {
                        NSNotificationCenter.defaultCenter().postNotificationName("deviceNotFound", object: nil)
                    }
                }
            }
            
            /*let connectedPeripherals = centralManager.retrieveConnectedPeripheralsWithServices(Constants.ADVERTISED_UUIDS)
            if connectedPeripherals.count > 0{
                print("retrieveConnectedPeripheralsWithServices \(connectedPeripherals)")
                for peripheral in connectedPeripherals{
                    let connectedPeripheral = peripheral
                    if connectedPeripheral.identifier.UUIDString == selectedClickey.uuid {
                    centralManager.connectPeripheral(connectedPeripheral, options: Constants.CONNECTION_OPTIONS)
                        break
                    }
                }
            }else{
                self.startScan()
                afterDelay(scanTimeout){
                    self.stopScan()
                    if self.connectedDevice == nil {
                        NSNotificationCenter.defaultCenter().postNotificationName("deviceNotFound", object: nil)
                    }
                }
            }*/
            
        case .PoweredOff:
            print("PoweredOff")
            NSNotificationCenter.defaultCenter().postNotificationName("showBlutoothMessage", object: nil, userInfo: ["title": "Bluetooth is uitgeschakeld", "message": "Om dit te doen moet je Bluetooth aan staan..."])
            
        default:
            print(central.state.rawValue)
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("willRestoreState \(dict)")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("didDiscoverPeripheral name:\(peripheral.name)  \nUUID:\(peripheral.identifier.UUIDString)  \nRSSI:\(RSSI)")
        //print(selectedClickey.uuid)
        isDeviceFound = true
        NSNotificationCenter.defaultCenter().postNotificationName("didDiscoverPeripheral", object: nil, userInfo: ["peripheral": peripheral])
        /*if peripheral.identifier.UUIDString == selectedClickey.uuid{
            print("found device")
            stopScan()
            connectPeripheral(peripheral)
        }*/
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("didConnectPeripheral \(peripheral.identifier.UUIDString)")
        var id = 0
        if selectedClickey != nil{
            id = selectedClickey.id
        }
        connectedDevice = ClickeyModel(id: id, peripheral: peripheral)
        PeripheralManager.sharedInstance.connectedDevice = connectedDevice
        PeripheralManager.sharedInstance.connectedDevice.peripheral.delegate = PeripheralManager.sharedInstance
        NSNotificationCenter.defaultCenter().postNotificationName("deviceConnected", object: nil)
        afterDelay(1.0){
            PeripheralManager.sharedInstance.startDiscoveringServices()
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if error != nil{
         print("didDisconnectPeripheral \(error.debugDescription)")
        }
        connectedDevice = nil
        NSNotificationCenter.defaultCenter().postNotificationName("deviceDisconnected", object: nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("didFailToConnectPeripheral message: \(error.debugDescription)")
    }
    
    func connectPeripheral(peripheral: CBPeripheral){
        print("connectPeripheral")
        let devices = centralManager.retrievePeripheralsWithIdentifiers([peripheral.identifier])
        if let firstDevice =  devices.first{
            centralManager.connectPeripheral(firstDevice, options: nil)
        }
    }
    
    func disconnectPeripheral(){
        if connectedDevice != nil{
            centralManager.cancelPeripheralConnection(connectedDevice.peripheral)
            connectedDevice = nil
            PeripheralManager.sharedInstance.unregisterNotifications()
            NSNotificationCenter.defaultCenter().postNotificationName("deviceDisconnected", object: nil)
        }
    }

    func startScan(){
        if !isScanning{
            centralManager.scanForPeripheralsWithServices(Constants.ADVERTISED_UUIDS, options: [CBCentralManagerScanOptionAllowDuplicatesKey: 0])
            //centralManager.scanForPeripheralsWithServices(nil, options: nil)
            isScanning = true
        }
    }
    
    func stopScan() {
        if isScanning{
            centralManager.stopScan()
            isScanning = false
        }else{
            disconnectPeripheral()
        }
    }

}
