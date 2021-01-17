//
//  AppConfig.swift
//  CoMap-19
//

//
//

import Foundation

class AppConfig: Codable {
  
  var maxCountReadWrite: Int
  var forceUpgrade: ForceUpgrade?
  
  init() {
    self.maxCountReadWrite = 10
  }
  
  private enum CodingKeys : String, CodingKey {
    case maxCountReadWrite = "max_count_read_write"
    case forceUpgrade = "is_force_upgrade_required_ios"
  }
  
  struct ForceUpgrade: Codable {
    var minVersion: String?
    var specificVersion: [String]?
    
    private enum CodingKeys : String, CodingKey {
      case minVersion = "min_version"
      case specificVersion = "specific_version"
    }
  }
}


