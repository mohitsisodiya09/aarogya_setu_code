//
//  DAOManager.swift
//  CoMap-19
//

//
//

import Foundation

enum FileOperationResult {
  case success
  case Failure
}

protocol DAOManager: AnyObject {
  func persistLocation(location: Location)
  func persist(identifier: String, rssi: NSNumber, txPower: String, location: Location)
  func saveToDisk(completion: @escaping (FileOperationResult) -> Void)
  func getUserData() -> [String: Any]?
}

typealias completionHandlder = ((FileOperationResult) -> Void)?

final class DAOManagerImpl: NSObject, DAOManager {
  
  var currentLocation: Location?
  
  fileprivate struct Defaults {
    static let userListFileName = "userList"
  }
  
  fileprivate var dataPointList: [Datapoint] = []
  
  fileprivate lazy var CONVERTING_KEY: String? = {
    return KeychainHelper.getConvertingKey()
  }()
  
  private override init() {
  }
  
  static let shared = DAOManagerImpl()
  
  // MARK: - Encryption/Decryption methods
  
  fileprivate func getConvertedString(text: String) -> String {
    
    if let textData = text.data(using: .utf8),
      let convertingKey = CONVERTING_KEY {
      
      do {
        let encryptedData = try ConvertingLogic(keyString: convertingKey).convert(textData)
        return encryptedData.base64EncodedString()
      }
      catch {
        //printForDebug(string: "error while convreting data")
      }
      
    }
    return ""
  }
  
  fileprivate func getOriginalString(text: String) -> String {
    
    if let convertingKey = CONVERTING_KEY,
      let data = Data(base64Encoded: text) {
      
      do {
        return try ConvertingLogic(keyString: convertingKey).convertback(data)
      }
      catch {
        //printForDebug(string: "error while converting back data")
      }
      
    }
    return ""
  }
  
  fileprivate func getConvertedDataList(dataList: [Datapoint]) -> [String] {
    var convertedDataString: [String] = []
    let encoder = JSONEncoder()
    
    guard let convertingKey = CONVERTING_KEY else {
      return []
    }
    
    for datapoint in dataList {
      do {
        let jsonData = try encoder.encode(datapoint)
        let encryptedData = try ConvertingLogic(keyString: convertingKey).convert(jsonData)
        
        convertedDataString.append(encryptedData.base64EncodedString())
      }
      catch {
        //printForDebug(string: "error while encrypting data")
      }
    }
    
    return convertedDataString
  }
  
  fileprivate func getOriginalDataList(dataList: [String]) -> [Datapoint]? {
    var decryptedDataList: [Datapoint] = []
    let decoder = JSONDecoder()
    
    guard let convertingKey = CONVERTING_KEY else {
      return nil
    }
    
    for datapoint in dataList {
      if let textEncryptedData = Data(base64Encoded: datapoint)  {
        do {
          let decryptedData = try ConvertingLogic(keyString: convertingKey).convertback(to: textEncryptedData)
          let dataPointObj = try decoder.decode(Datapoint.self, from: decryptedData)
          decryptedDataList.append(dataPointObj)
        }
        catch {
          //printForDebug(string: "error while encrypting data")
        }
      }
    }
    
    return decryptedDataList.isEmpty ? nil : decryptedDataList
  }
  
  fileprivate func differenceInDays(startDateTs: String, endDate: Date) -> Int {
    if let startDateTs = Double(startDateTs) {
      let startDate = Date(timeIntervalSince1970: startDateTs)
      return endDate.difference(ofComponent: .day, fromDate: startDate)
    }
    
    return 0
  }
  
  fileprivate func prepareUserList(dataPointList: [Datapoint]) -> UserList {
    let mobileNumber = UserDefaults.standard.value(forKey: "mobileNumber") as? String ?? ""
    let uuid = KeychainHelper.getDeviceId() ?? ""
    
    return UserList(m: getConvertedString(text: mobileNumber),
                    d: getConvertedString(text: uuid),
                    data: getConvertedDataList(dataList: dataPointList))
  }
  
  fileprivate func getCurrentTimeStampString() -> String {
    return String(format: "%d", Int(Date().timeIntervalSince1970))
  }
  
  fileprivate func eraseExpiredData(userList: UserList) -> UserList {
    var lastIndexToRemove: Int?
    let todaysDate = Date()
    
    guard let decryptedDataPointList = getOriginalDataList(dataList: userList.data) else{
      return userList
    }
    
    for (index, value) in decryptedDataPointList.enumerated() {
      if differenceInDays(startDateTs: value.ts, endDate: todaysDate) > Constants.maxDataPersistingDays {
        lastIndexToRemove = index
      }
      else {
        break
      }
    }
    
    if let lastIndex = lastIndexToRemove, lastIndex + 1 <= userList.data.count {
      let dataPointsNotToBeErased = Array(userList.data.suffix(from: lastIndex + 1))
      return UserList(m: userList.m, d: userList.d, data: dataPointsNotToBeErased)
    }
    
    return userList
  }
  
   func writeData(userList: UserList, completion: ((FileOperationResult) -> Void)?) {
    
    let jsonEncoder = JSONEncoder()
    do{
      let jsonData = try jsonEncoder.encode(userList)
      try FileParser.writeJson(jsonData: jsonData, source: .documentDirectory, fileName: Defaults.userListFileName)
      dataPointList.removeAll()
      completion?(.success)
    }
    catch _ {
      //printForDebug(string: error.localizedDescription)
      completion?(.Failure)
    }
  }
  
  // MARK: - DAOManager methods implementation
  
  func persist(identifier: String, rssi: NSNumber, txPower: String, location: Location) {
    
    let newDevice = Device(d: identifier, dist: rssi.intValue, tx_power: txPower, tx_level: "")
    let newDataPoint = Datapoint(ts: getCurrentTimeStampString(),
                                 l: location,
                                 dl: [newDevice])
    
    if dataPointList.count == Constants.appConfig?.maxCountReadWrite {
      
      saveToDisk { [weak self] (fileOperationResult) in
        guard let strongSelf = self else {
          return
        }
        
        switch fileOperationResult {
        case .success:
          strongSelf.dataPointList.append(newDataPoint)
        case .Failure:
          break
        }
      }
      
    }
    else {
      dataPointList.append(newDataPoint)
    }
  
  }
  
  func persistLocation(location: Location) {
    let newDataPoint = Datapoint(ts: getCurrentTimeStampString(),
                                 l: location,
                                 dl: [])
    dataPointList.append(newDataPoint)
    saveToDisk { (_) in
      
    }
  }
  
  func deleteOldData() throws -> UserList {
    let oldjson = try FileParser.readJson(fileName: Defaults.userListFileName, source: .documentDirectory)
    
    let jsonData = try JSONSerialization.data(withJSONObject: oldjson, options: .prettyPrinted)
    
    let oldUserList = try JSONDecoder().decode(UserList.self, from: jsonData)
    
    if !oldUserList.data.isEmpty {
      return eraseExpiredData(userList: oldUserList)
    }
    else {
      return oldUserList
    }
  }
  
  func saveToDisk(completion: @escaping (FileOperationResult) -> Void) {
    
    do {
      var updatedUserList = try deleteOldData()
      let encryptedDataList = getConvertedDataList(dataList: dataPointList)
      updatedUserList.data.append(contentsOf: encryptedDataList)
      writeData(userList: updatedUserList, completion: completion)
      
    }
    catch let e {
      if let err = e as? FileReadingError {
        if err.kind == .fileNotFound {
          writeData(userList: prepareUserList(dataPointList: dataPointList), completion: completion)
        }
      }
    }
  }
  
  func getUniqueContactCount() -> Int {
    
    var uniqueContact = Set<String>()
    do {
      let oldjson = try FileParser.readJson(fileName: Defaults.userListFileName, source: .documentDirectory)
      
      let jsonData = try JSONSerialization.data(withJSONObject: oldjson, options: [])
      let oldUserList = try JSONDecoder().decode(UserList.self, from: jsonData)
      
      if let decryptedDataList = getOriginalDataList(dataList: oldUserList.data) {
        for dataPoint in decryptedDataList {
          for device in dataPoint.dl {
            uniqueContact.insert(device.d)
          }
        }
      }
    }
    catch _ {
      return uniqueContact.count
    }
    
    return uniqueContact.count
  }
  
  func getUserData() -> [String: Any]? {
    let encoder = JSONEncoder()
    
    do {
      let oldjson = try FileParser.readJson(fileName: Defaults.userListFileName, source: .documentDirectory)
      let jsonData = try JSONSerialization.data(withJSONObject: oldjson, options: .prettyPrinted)
      let oldUserList = try JSONDecoder().decode(UserList.self, from: jsonData)
      
      let mobileNumber = UserDefaults.standard.value(forKey: "mobileNumber") as? String ?? ""
      let uuid = KeychainHelper.getDeviceId() ?? ""
      
      if let decryptedDataList = getOriginalDataList(dataList: oldUserList.data) {
        let decryptedUserList = DataToPost(m: mobileNumber,
                                           d: uuid,
                                           data: decryptedDataList)
        
        let data = try encoder.encode(decryptedUserList)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        
        return json as? [String: Any]
      }
      
    }
    catch _ {
      return nil
    }
    
    return nil
  }
  
  //  func removeData() {
  //    do {
  //      try FileParser.removeContenOfFileInDocumentDirectory(fileName: Defaults.userListFileName,
  //                                                           fileExtension: Constants.FileExtensions.json)
  //    }
  //    catch _ {
  //    }
  //  }
  
}
