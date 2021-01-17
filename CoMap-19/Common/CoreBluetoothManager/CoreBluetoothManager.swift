//
//  CoreBluetoothManager.swift
//  Comap
//

//

import UIKit
import Foundation
import CoreBluetooth
import CoreLocation

//protocol CoreBluetoothManager: AnyObject {
//  func startScanningNearbyDevices()
//  func stopScanningNearbyDevices()
//}

protocol CoreBluetoothManagerDelegate: AnyObject {
  func didDiscoverNearbyDevices(identifier: String, rssi: NSNumber, txPower: String)
}

final class CoreBluetoothManagerImpl: NSObject {
  
  fileprivate var centralManager: CBCentralManager!
  fileprivate var peripheralManager: CBPeripheralManager!
  fileprivate let SERVICE_UUID = CBUUID(string: "45ED2B0C-50F9-4D2D-9DDC-C21BA2C0F825")

  private var scannedBLEUUIDsDIDInfo = [UUID:String]()
  private var scannedBLEUUIDsTxPowerInfo = [UUID:String]()
  private var scannedDIDsTxPowerInfo = [String:String]()

  weak var delegate: CoreBluetoothManagerDelegate?
  
  // MARK: - Fileprivate methods
  
  fileprivate func updateAdvertisingData() {
    
    if (peripheralManager.isAdvertising) {
      peripheralManager.stopAdvertising()
    }
    
    guard let uuid = KeychainHelper.getDeviceId() else {
      return assertionFailure("Could not retrieve device id")
    }
    let advertisementData = String(format: "%@", uuid)
    
    peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID], CBAdvertisementDataLocalNameKey: advertisementData, CBAdvertisementDataTxPowerLevelKey: true])
  }
    
  func startScanningNearbyDevices() {
    centralManager = CBCentralManager(delegate: self, queue: .main)
    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
  }
  
  func stopScanningNearbyDevices() {
    centralManager.stopScan()
    peripheralManager.stopAdvertising()
  }
  
}

extension CoreBluetoothManagerImpl : CBPeripheralManagerDelegate {
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if (peripheral.state == .poweredOn){
      updateAdvertisingData()
    }
  }
  
}


extension CoreBluetoothManagerImpl: CBCentralManagerDelegate {
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      UserDefaults.standard.set(true, forKey: "isBluetoothOn")
      centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options:
        [CBCentralManagerScanOptionAllowDuplicatesKey : false])
    }else if central.state == .unauthorized{
        UserDefaults.standard.set(false, forKey: "isBluetoothOn")
        AlertView.showBluetoothAlert(internetConnectionLost: {
            //Open Setting for Bluetooth
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            let app = UIApplication.shared
            app.open(url)
        }) {
            //Cancel Do Nothing
        }
    }else {
      UserDefaults.standard.set(false, forKey: "isBluetoothOn")
      printForDebug(string: "make sure your bluetooth in ON")
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
      
    var deviceId: String?
    
    if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
      deviceId = advertisementName
      scannedBLEUUIDsDIDInfo[peripheral.identifier] = deviceId
    }
    else if let peripheralNameValue = peripheral.name{
      deviceId = peripheralNameValue
      scannedBLEUUIDsDIDInfo[peripheral.identifier] = deviceId
    }
    else if let savedDeviceId = scannedBLEUUIDsDIDInfo[peripheral.identifier]{
      deviceId = savedDeviceId
    }
        
    var txPower = ""
    if let txPowerValue = advertisementData[CBAdvertisementDataTxPowerLevelKey]{
      txPower = "\(txPowerValue)"
      scannedBLEUUIDsTxPowerInfo[peripheral.identifier] = txPower
      if let did = deviceId{
        scannedDIDsTxPowerInfo[did] = txPower
      }
    }
    else if let txPowerValue = scannedBLEUUIDsTxPowerInfo[peripheral.identifier]{
      txPower = "\(txPowerValue)"
    }
    else if let did = deviceId, let txPowerValue = scannedDIDsTxPowerInfo[did]{
      txPower = "\(txPowerValue)"
    }
    
    if let name = deviceId {
      delegate?.didDiscoverNearbyDevices(identifier: name, rssi: RSSI, txPower: txPower)
    }
    
    print("TimeStamp-\(Date()) ****28BytesData****PeripheralId-\(peripheral.identifier.uuidString)****TxPower-\(txPower)****RSSI-\(RSSI)****10BytesData****PeripheralAdvServiceLocalName-\(String(describing: deviceId))")
  }
  
}
