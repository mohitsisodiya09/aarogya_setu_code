//
//  StatusMsmeRequest.swift
//  CoMap-19
//

//

import Foundation

struct StatusMsmeRequest: Decodable {
  
  private(set) var did: String
  private(set) var message: String?
  private(set) var name: String?
  private(set) var mobileNumber: String?
  private(set) var colorCode: String?
  
  private enum CodingKeys: String, CodingKey {
    case did
    case message
    case name
    case mobileNumber = "mobile_no"
    case colorCode = "color_code"
  }
}
