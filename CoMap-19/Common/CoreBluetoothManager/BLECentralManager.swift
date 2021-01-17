//
//  BLECentralManager.swift
//  BLEExperiment
//

//

import Foundation
import CoreBluetooth

protocol BLECentralManagerScannerProtocol {
  func startScanning()
  func stopScanning()
}

protocol BLECentralManagerScannerDelegate : AnyObject{
  func didDiscoverNearbyDevices(identifier: String, rssi: NSNumber, txPower: String, platform: String)
}

class BLECentralManager: NSObject{
  
  private let centralRoleEventsSerialQueue = DispatchQueue(label: BLEConstants.CentralRoleEventSerialQueue)
  
  private let centralPeripheralConcurrentQueue = DispatchQueue(label: BLEConstants.CentralPeripheralReadWriteSafeConcurrentQueue, attributes: .concurrent)
  
  private lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: centralRoleEventsSerialQueue, options: [CBCentralManagerOptionShowPowerAlertKey:true])
  
  lazy private var scannedBLEUUIDsDIDInfo = [String : String]()
  
  lazy private var scannedBLEUUIDsTxPowerInfo = [String : String]()
  
  lazy private var scannedDIDsTxPowerInfo = [String : String]()
  
  lazy private var scannedPeripherals = [String:CBPeripheral]()
    
  lazy private var pinggers = [String:CBCharacteristic]()
  
  lazy private var scannedDIDsPlatform = [String:String]()
  
  private var deviceInfoTimer = Timer()
  
  weak var delegate: BLECentralManagerScannerDelegate?
  
  override init() {
    super.init()
    _ = centralManager
    
    let timerInterval = Double(RemoteConfigManager.shared.getIntValueFor(key: RemoteConfigKeys.scanPollTime) ?? RemoteConfigDefaults.scanPollTime)
    
    deviceInfoTimer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(retriveConnectedPeripheralInfo), userInfo: nil, repeats: true)
  }
}

extension BLECentralManager: BLECentralManagerScannerProtocol{
  
  func startScanning(){
    debugPrint("Starting scanning")
    centralManager.scanForPeripherals(withServices: [BLEConstants.AdvertisementAarogyaServiceCBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
  }
  
  func stopScanning(){
    debugPrint("Stopping scanning")
    centralManager.stopScan()
  }
}

extension BLECentralManager: CBCentralManagerDelegate{
  
  func centralManagerDidUpdateState(_ central: CBCentralManager){
    if central.state == .poweredOn{
      startScanning()
      UserDefaults.standard.set(true, forKey: Constants.UserDefault.isBluetoothOn)
    }
    else{
      stopScanning()
      UserDefaults.standard.set(false, forKey: Constants.UserDefault.isBluetoothOn)
    }
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
    
    let deviceId = peripheralDeviceId(forDiscoveredPeripheral: peripheral, andAdvertisementData: advertisementData)
    
    let txPower = peripheralTxPower(forDiscoveredPeripheral: peripheral, andDeviceId: deviceId, andAdvertisementData: advertisementData)
    
    
    centralPeripheralConcurrentQueue.async(flags: .barrier){ [weak self] in
      if self?.scannedPeripherals[peripheral.identifier.uuidString] == nil {
        if let name = deviceId{
          debugPrint("Values through disconnected scanned device - \(peripheral.identifier):")
          self?.delegate?.didDiscoverNearbyDevices(identifier: name, rssi: RSSI, txPower: txPower, platform: "")
        }
        else{
          debugPrint("Device id nil case for \(peripheral.identifier)-DeviceIdNil-\(RSSI)-\(txPower)-PlatformNil")
        }
        
        self?.scannedPeripherals[peripheral.identifier.uuidString] = peripheral
        
        self?.centralManager.connect(peripheral, options: nil)
        debugPrint("Connecting to \(peripheral.identifier)")
      }
      else{
        // do nothing
      }
    }
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    debugPrint("Connected to \(peripheral.identifier)")
    centralPeripheralConcurrentQueue.sync{ [weak self] in
      self?.scannedPeripherals[peripheral.identifier.uuidString]?.delegate = self
      self?.scannedPeripherals[peripheral.identifier.uuidString]?.discoverServices([BLEConstants.AdvertisementAarogyaServiceCBUUID])
    }
  }
  
  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    centralPeripheralConcurrentQueue.async(flags: .barrier){ [weak self] in
      self?.scannedPeripherals[peripheral.identifier.uuidString] = nil
      debugPrint("Removed - \(peripheral)")
    }
    debugPrint("Fail to connect to \(peripheral.identifier)- Error-\(String(describing: error))")
  }
  
  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    
    if let error = error as NSError?, error.domain == CBErrorDomain, (error.code == CBError.Code.connectionTimeout.rawValue) {
      self.centralManager.connect(peripheral, options: nil)
    }
    else{
      centralPeripheralConcurrentQueue.async(flags: .barrier){ [weak self] in
        self?.scannedPeripherals[peripheral.identifier.uuidString] = nil
        debugPrint("Removed - \(peripheral)")
      }
    }
    debugPrint("Disconnected from \(peripheral.identifier)-Error-\(String(describing: error))")
  }
}

extension BLECentralManager : CBPeripheralDelegate{
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
    
    guard let services = peripheral.services, services.count > 0 else{
      debugPrint("peripheralDidDiscoverServices of \(peripheral.identifier) - Service count - \(peripheral.services?.count ?? 0) - \(String(describing: error))")
      centralManager.cancelPeripheralConnection(peripheral)
      return
    }
    
    debugPrint("peripheralDidDiscoverServices of \(peripheral.identifier) - Service count - \(services.count)")
    
    for service in services {
      peripheral.discoverCharacteristics([BLEConstants.PeripheralAarogyaServiceDeviceCharactersticCBUUID, BLEConstants.PeripheralAarogyaServiceDevicePinggerCBUUID, BLEConstants.PeripheralAarogyaServiceDeviceOSCBUUID], for: service)
      
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
    debugPrint("peripheralDidDiscoverCharacteristics of \(peripheral.identifier) for aarogya service")
    
    if let characteristics = service.characteristics{
      
      for characteristic in characteristics{
        if characteristic.uuid == BLEConstants.PeripheralAarogyaServiceDeviceCharactersticCBUUID{
          retrieveData(forCharacterstic: characteristic, fromPeripheral: peripheral)
        }
        else if characteristic.uuid == BLEConstants.PeripheralAarogyaServiceDevicePinggerCBUUID{
          centralPeripheralConcurrentQueue.async(flags : .barrier){ [weak self] in
            self?.pinggers[peripheral.identifier.uuidString] = characteristic
          }
        }
        else if characteristic.uuid == BLEConstants.PeripheralAarogyaServiceDeviceOSCBUUID{
          retrieveData(forCharacterstic: characteristic, fromPeripheral: peripheral)
        }
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
    
    if let valueData = characteristic.value{
      switch characteristic.uuid {
      case BLEConstants.PeripheralAarogyaServiceDeviceCharactersticCBUUID:
        if let stringValue = String(data: valueData, encoding: .utf8), stringValue != BLEConstants.PeripheralDIDEqualsNil, !stringValue.isEmpty{
          centralPeripheralConcurrentQueue.async(flags : .barrier){ [weak self] in
            self?.scannedBLEUUIDsDIDInfo[peripheral.identifier.uuidString] = stringValue
          }
        }
        else{
          centralManager.cancelPeripheralConnection(peripheral)
        }
        debugPrint("\(Date())********Peripheral=\(peripheral.identifier)****AarogyaServiceDeviceCharactersticValue=\(String(describing: String(data: valueData, encoding: .utf8)))")
      case BLEConstants.PeripheralAarogyaServiceDevicePinggerCBUUID:
        let boolValue = valueData.withUnsafeBytes {
          $0.load(as: Bool.self)
        }
        debugPrint("\(Date())********Peripheral=\(peripheral.identifier)****AarogyaServiceDevicePinggerValue=\(boolValue)")
      case BLEConstants.PeripheralAarogyaServiceDeviceOSCBUUID:
        if let stringValue = String(data: valueData, encoding: .utf8){
          centralPeripheralConcurrentQueue.async(flags : .barrier){ [weak self] in
            if let deviceId = self?.scannedBLEUUIDsDIDInfo[peripheral.identifier.uuidString]{
              self?.scannedDIDsPlatform[deviceId] = stringValue
            }
          }
          debugPrint("\(Date())********Peripheral=\(peripheral.identifier)****AarogyaServiceDeviceOSCBUUID=\(stringValue)")
        }
      default:
        debugPrint("Unhandled Characteristic UUID: \(characteristic.uuid)")
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?){
    
    debugPrint("\(Date())****Peripheral=\(peripheral.identifier)****RSSI=\(RSSI)")
    
    centralPeripheralConcurrentQueue.sync{ [weak self] in
      if let deviceId = self?.scannedBLEUUIDsDIDInfo[peripheral.identifier.uuidString]{
        let platform = self?.scannedDIDsPlatform[deviceId] ?? "A"
        let txPower = self?.scannedDIDsTxPowerInfo[deviceId] ?? ""
        debugPrint("Values through connected device - \(peripheral.identifier):")
        self?.delegate?.didDiscoverNearbyDevices(identifier: deviceId as String, rssi: RSSI, txPower: txPower, platform: platform as String)
      }
      else{
        debugPrint("Incomplete values through connected device - \(peripheral.identifier):")
      }
    }
  }
  
}

private extension BLECentralManager{
  
  func peripheralDeviceId(forDiscoveredPeripheral peripheral : CBPeripheral, andAdvertisementData advertisementData : [String : Any]) -> String? {
    var deviceId: String?
    
    // Storing peripheral UUIDs id required as when app moves to BG
    // The device name can be nil, as per apple doc - Core Bluetooth Background guide
    // To avoid sending nil or empty device id we have mapped once found device id to a peripheral id which remains consistent till BLE is turned OFF
    centralPeripheralConcurrentQueue.async(flags : .barrier){ [weak self] in
      if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, !advertisementName.isEmpty {
        deviceId = advertisementName
        self?.scannedBLEUUIDsDIDInfo[peripheral.identifier.uuidString] = deviceId
      }
    }
    
    centralPeripheralConcurrentQueue.sync{ [weak self] in
      if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String, !advertisementName.isEmpty {
        deviceId = advertisementName
      }
      else if let savedDeviceId = self?.scannedBLEUUIDsDIDInfo[peripheral.identifier.uuidString], !savedDeviceId.isEmpty{
        deviceId = savedDeviceId
      }
    }
    
    return deviceId
  }
  
  func peripheralTxPower(forDiscoveredPeripheral peripheral : CBPeripheral, andDeviceId deviceId : String?, andAdvertisementData advertisementData : [String : Any]) -> String {
    // There is inconsistency in deriving Tx value, the value is only available when central is in FG and peripheral is in BG
    // To reduce sending nil values of Tx, mapping is done.
    
    centralPeripheralConcurrentQueue.async(flags : .barrier){ [weak self] in
      if let txPowerValue = advertisementData[CBAdvertisementDataTxPowerLevelKey]{
        self?.scannedBLEUUIDsTxPowerInfo[peripheral.identifier.uuidString] = "\(txPowerValue)"
        if let did = deviceId{
          self?.scannedDIDsTxPowerInfo[did] = "\(txPowerValue)"
        }
      }
    }
    
    var txPower = ""
    centralPeripheralConcurrentQueue.sync{ [weak self] in
      if let txPowerValue = advertisementData[CBAdvertisementDataTxPowerLevelKey]{
        txPower = "\(txPowerValue)"
      }
      else if let txPowerValue = self?.scannedBLEUUIDsTxPowerInfo[peripheral.identifier.uuidString], !txPowerValue.isEmpty{
        txPower = "\(txPowerValue)"
      }
      else if let did = deviceId, let txPowerValue = self?.scannedDIDsTxPowerInfo[did], !txPowerValue.isEmpty{
        txPower = "\(txPowerValue)"
      }
    }
    return txPower
  }
  
  @objc func retriveConnectedPeripheralInfo() {
    
    debugPrint("\nCheck scanned devices state")
    
    var scannedPeripheralsCopy = [String:CBPeripheral]()
    
    centralPeripheralConcurrentQueue.sync{ [weak self] in
      debugPrint("All scanned devices \(String(describing: self?.scannedPeripherals))")
      
      if let count = self?.scannedPeripherals.keys.count, count > 0, let scannedPeripherals = self?.scannedPeripherals{
        
        scannedPeripheralsCopy = scannedPeripherals
      }
    }
    
    debugPrint("All scanned devices copy \(scannedPeripheralsCopy)")
    centralPeripheralConcurrentQueue.async(flags: .barrier){ [weak self] in
      for (peripheralId, peripheralObject) in scannedPeripheralsCopy{
        if peripheralObject.state == .connected{
          if let pinggerCharacteristic = self?.pinggers[peripheralObject.identifier.uuidString]{
            self?.retrieveData(forCharacterstic: pinggerCharacteristic, fromPeripheral: peripheralObject)
          }
          peripheralObject.readRSSI()
        }
        else{
          self?.centralManager.connect(peripheralObject, options:nil)
          self?.scannedPeripherals[peripheralId] = nil
          debugPrint("Removed - \(peripheralObject)")
        }
      }
    }
  }
  
  func retrieveData(forService service : CBService, fromPeripheral peripheral: CBPeripheral) {
    
    if let characteristics = service.characteristics{
      for characteristic in characteristics{
        retrieveData(forCharacterstic: characteristic, fromPeripheral: peripheral)
      }
    }
  }
  
  func retrieveData(forCharacterstic characteristic :  CBCharacteristic, fromPeripheral peripheral: CBPeripheral) {
    switch characteristic.uuid {
    case BLEConstants.PeripheralAarogyaServiceDeviceCharactersticCBUUID:
      peripheral.readValue(for: characteristic)
    case BLEConstants.PeripheralAarogyaServiceDevicePinggerCBUUID:
      peripheral.readValue(for: characteristic)
    case BLEConstants.PeripheralAarogyaServiceDeviceOSCBUUID:
      peripheral.readValue(for: characteristic)
    default:
      debugPrint("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
  }
}
