//
//  QrPayload.swift
//  CoMap-19
//

//
//

import SwiftJWT
import Foundation

enum HealthStatus {
  case low
  case moderate
  case high
  case testedPositive
  case none
  
  static func getStatusForCode(_ code: Int) -> HealthStatus {
    switch code {
    case 100, 200, 301, 302, 800: return .low
    case 400, 401, 402, 403: return .moderate
    case 500, 501, 502, 600: return .high
    case 700, 1000: return .testedPositive
    default: return .none
    }
  }
}

struct QrPayload: Codable {
  var statusCode: Int
  var mobileNumber: String
  var expirationTimeStamp: Double
  var fullName: String?
  var message: String?
  var colorCode: String?
  
  private enum CodingKeys: String, CodingKey {
    case statusCode = "status_code"
    case mobileNumber = "mobile_no"
    case expirationTimeStamp = "exp"
    case fullName = "name"
    case colorCode = "color_code"
    case message = "message"
  }
}

struct MyClaims: Claims { }
