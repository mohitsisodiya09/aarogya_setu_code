//
//  BLEPeripheralManager.swift
//  BLEExperiment
//
//

import Foundation
import CoreBluetooth

protocol BLEPeripheralManagerProtocol {
  func startAdvertisingService()
  func stopAdvertisingService()
}

class BLEPeripheralManager: NSObject {
  
  private let peripheralRoleEventsSerialQueue = DispatchQueue(label: BLEConstants.PeripheralRoleEventSerialQueue)
  
  private lazy var peripheralManager : CBPeripheralManager = CBPeripheralManager.init(delegate: self, queue: peripheralRoleEventsSerialQueue, options: [CBPeripheralManagerOptionShowPowerAlertKey:true])
  
  private let permissions: CBAttributePermissions = [.readable]
  
  private lazy var deviceIdCharactersticValue : Data? = {
    guard let deviceId = KeychainHelper.getDeviceId() else {
      assertionFailure("Could not retrieve device id")
      return dataFrom(stringTypeValue: BLEConstants.PeripheralDIDEqualsNil) ?? nil
    }
    let deviceIdCharactersticValue = dataFrom(stringTypeValue: deviceId)
    return deviceIdCharactersticValue
  }()
  
  private lazy var aarogyaServiceDeviceCharacteristic = CBMutableCharacteristic(type: BLEConstants.PeripheralAarogyaServiceDeviceCharactersticCBUUID, properties: [.read], value:deviceIdCharactersticValue, permissions: permissions)
  
  private lazy var deviceCharactersticPinggerValue = dataFrom(boolTypeValue: true)
  
  private lazy var aarogyaServiceDevicePingger = CBMutableCharacteristic(type: BLEConstants.PeripheralAarogyaServiceDevicePinggerCBUUID, properties: [.read], value:deviceCharactersticPinggerValue, permissions: permissions)
  
  private lazy var deviceCharactersticDeviceOSValue = dataFrom(stringTypeValue: "I")
  
  private lazy var aarogyaServiceDeviceOSCharacteristic = CBMutableCharacteristic(type: BLEConstants.PeripheralAarogyaServiceDeviceOSCBUUID, properties: [.read], value:deviceCharactersticDeviceOSValue, permissions: permissions)
  
  private lazy var aarogyaService = CBMutableService(type:BLEConstants.AdvertisementAarogyaServiceCBUUID , primary: true)
  
  override init() {
    super.init()
    
    aarogyaService.characteristics = [aarogyaServiceDeviceCharacteristic, aarogyaServiceDevicePingger, aarogyaServiceDeviceOSCharacteristic]
    
    _ = peripheralManager
  }
}

extension BLEPeripheralManager:BLEPeripheralManagerProtocol{
  func startAdvertisingService(){
    if peripheralManager.isAdvertising{
      peripheralManager.stopAdvertising()
    }
    
    guard let deviceId = KeychainHelper.getDeviceId() else {
      return assertionFailure("Could not retrieve device id")
    }
    let advertiserLocalName = String(format: "%@", deviceId)
    peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[BLEConstants.AdvertisementAarogyaServiceCBUUID], CBAdvertisementDataLocalNameKey: advertiserLocalName, CBAdvertisementDataTxPowerLevelKey: true])
  }
  
  func stopAdvertisingService(){
    peripheralManager.stopAdvertising()
  }
}

extension BLEPeripheralManager: CBPeripheralManagerDelegate{
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    if peripheral.state == .poweredOn{
      
      peripheralManager.removeAllServices()
      peripheralManager.add(aarogyaService)
    }
    else{
      stopAdvertisingService()
    }
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    debugPrint("Added aarogya service")
    
    stopAdvertisingService()
    startAdvertisingService()
  }
  
  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    debugPrint("Started advertising/ broadcasting aarogya service")
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    if request.characteristic.uuid == self.aarogyaServiceDeviceCharacteristic.uuid{
      peripheralManager.respond(to: request, withResult: .success)
    }
  }
  
  func respond(to request: CBATTRequest, withResult result: CBATTError.Code){
    debugPrint("Read request")
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic){
    debugPrint("Subscribed to notification")
  }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic){
    debugPrint("UnSubscribed to notification")
  }
}

extension BLEPeripheralManager{
  
  private func dataFrom(floatTypeValue floatValue:Float64) -> Data {
    var floatValueCopy = floatValue
    let floatData = Data(buffer: UnsafeBufferPointer(start: &floatValueCopy, count: 1))
    return floatData
  }
  
  private func dataFrom(stringTypeValue stringValue:String) -> Data?{
    let stringValueCopy = stringValue
    if let stringData = stringValueCopy.data(using: .utf8){
      return stringData
    }
    else{
      return nil
    }
  }
  
  private func dataFrom(boolTypeValue boolValue:Bool) -> Data {
    var boolValueCopy = boolValue
    let boolData = Data(buffer: UnsafeBufferPointer(start: &boolValueCopy, count: 1))
    return boolData
  }
}

