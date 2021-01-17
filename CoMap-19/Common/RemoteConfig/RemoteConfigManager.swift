//
//  RemoteConfigManager.swift
//  CoMap-19
//

//
//

import FirebaseRemoteConfig

typealias RemoteConfigCompletionBlock = (_ error: Error?) -> Void

struct RemoteConfigDefaults {
  static let scanPollTime = 30
   static let blurLocationMeter = 125
  static let launchCountForRating = 0
}

protocol RemoteConfigManagerProtocol {
  func getIntValueFor(key: String) -> Int?
  func fetchRemoteConfig()
}

final class RemoteConfigKeys: NSObject {
  static let scanPollTime = "scan_poll_time_ios"
  static let blurLocationMeter = "blur_location_meter_ios"
  static let uploadEnable = "upload_enable"
  static let disableSyncChoice = "disable_sync_choice"
  static let launchCountForRating = "launch_count_for_rating"
}

final class RemoteConfigManager: NSObject {
  
  static let shared = RemoteConfigManager()
  
  fileprivate lazy var config = RemoteConfig.remoteConfig()
  
  // MARK: - Private Variable
  
  fileprivate var completionBlock: RemoteConfigCompletionBlock?
  
  // MARK: - Private Constructor
  
  private override init() {
    super.init()
    
    initializeConfig()
  }
}

extension RemoteConfigManager {
  
  fileprivate func initializeConfig() {
    let debugSettings = RemoteConfigSettings()
    config.configSettings = debugSettings
    config.setDefaults(fromPlist: Defaults.remoteConfigPlistName)
  }
  
  fileprivate func fetchCloudValues(completionBlock: @escaping RemoteConfigCompletionBlock) {
    
    let remoteConfigDataRefreshDuration: TimeInterval = Defaults.dataRefetchInterval
    
    self.completionBlock = completionBlock
    
    config.fetch(withExpirationDuration: remoteConfigDataRefreshDuration) { [weak self] (status, error) in
      
      guard let strongSelf = self else {
        return
      }
      if error == nil {
        strongSelf.config.activate(completionHandler: nil)
      }
      completionBlock(error)
    }
  }
  
}

extension RemoteConfigManager: RemoteConfigManagerProtocol {
  
  func getIntValueFor(key: String) -> Int? {
    let remoteConfigValue = config.configValue(forKey: key)
    return remoteConfigValue.numberValue?.intValue
  }
  
  func getBoolValueFor(key: String) -> Bool {
    let remoteConfigValue = config.configValue(forKey: key)
    return remoteConfigValue.boolValue
  }
  
  func fetchRemoteConfig(){
    fetchCloudValues { (error) in
      
    }
  }
}

extension RemoteConfigManager {
  
  // MARK: - Constants
  
  fileprivate struct Defaults {
    static let dataRefetchInterval: TimeInterval = {
      return 900
    }()
    
    static let remoteConfigPlistName = "RemoteConfigDefaults"
  }
}
