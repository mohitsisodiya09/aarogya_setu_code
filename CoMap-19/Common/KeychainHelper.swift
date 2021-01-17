//
//  KeychainHelper.swift
//  CoMap-19
//

//
//

import Foundation
import KeychainSwift

class KeychainHelper {
  
  static func saveQrMetaData(_ metaData: String) {
    let keychain = KeychainSwift()
    keychain.set(metaData, forKey: Constants.Keychain.qrMetaData)
    return
  }
  
  static func getQrMetaData() -> String? {
    let keychain = KeychainSwift()
    return keychain.get(Constants.Keychain.qrMetaData)
  }
  
  static func removeQrMetaData() {
    let keychain = KeychainSwift()
    keychain.delete(Constants.Keychain.qrMetaData)
  }
  
  static func saveQrPublicKey(_ publicKey: String) {
    let keychain = KeychainSwift()
    keychain.set(publicKey, forKey: Constants.Keychain.qrPublicKey)
    return
  }
  
  static func getQrPublicKey() -> String? {
    let keychain = KeychainSwift()
    return keychain.get(Constants.Keychain.qrPublicKey)
  }
  
  static func saveName(_ name: String) {
    let keychain = KeychainSwift()
    keychain.set(name, forKey: Constants.Keychain.name)
    return
  }
  
  static func getName() -> String? {
    let keychain = KeychainSwift()
    return keychain.get(Constants.Keychain.name)
  }
  
  static func removeName() {
    let keychain = KeychainSwift()
    keychain.delete(Constants.Keychain.name)
  }

  static func saveDeviceId(_ deviceId: String) {
    let keychain = KeychainSwift()
    keychain.set(deviceId, forKey: Constants.Keychain.deviceId)
    
    let nc = NotificationCenter.default
    nc.post(name: .deviceIdSaved, object: nil)
  }
  
  static func getDeviceId() -> String?{
    let keychain = KeychainSwift()
    
    if let deviceId = keychain.get(Constants.Keychain.deviceId){
      return deviceId
    }
    else{
      return nil;
    }
  }
  
  static func saveConvertingKey(_ key: String) {
    let keychain = KeychainSwift()
    keychain.set(key, forKey: Constants.Keychain.convertingKey)
    return
  }
  
  static func getConvertingKey() -> String? {
    let keychain = KeychainSwift()

    if let uuid = keychain.get(Constants.Keychain.convertingKey){
      return uuid
    }
    else{
      return nil;
    }
  }
  
  static func saveAwsToken(_ token: String) {
    let keychain = KeychainSwift()
    keychain.set(token, forKey: Constants.Keychain.awsToken)
  }
  
  static func getAwsToken() -> String? {
    let keychain = KeychainSwift()
    return keychain.get(Constants.Keychain.awsToken)
  }
  
  static func removeAwsToken() {
    let keychain = KeychainSwift()
    keychain.delete(Constants.Keychain.awsToken)
  }
    
    static func saveRefreshToken(_ token: String) {
      let keychain = KeychainSwift()
      keychain.set(token, forKey: Constants.Keychain.refreshToken)
    }
    
    static func getRefreshToken() -> String? {
      let keychain = KeychainSwift()
      return keychain.get(Constants.Keychain.refreshToken)
    }
  
  static func removeRefreshToken() {
    let keychain = KeychainSwift()
    keychain.delete(Constants.Keychain.refreshToken)
  }
  
  static func saveMobileNumber(_ number: String?) {
    if let number =  number {
      let keychain = KeychainSwift()
      keychain.set(number, forKey: Constants.Keychain.mobileNumber)
    }
  }
  
  static func getMobileNumber() -> String? {
    let keychain = KeychainSwift()
    return keychain.get(Constants.Keychain.mobileNumber)
  }
  
  static func removeMobileNumber() {
    let keychain = KeychainSwift()
    keychain.delete(Constants.Keychain.mobileNumber)
  }

}
