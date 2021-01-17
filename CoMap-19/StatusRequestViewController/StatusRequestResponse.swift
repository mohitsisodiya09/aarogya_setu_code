//
//  StatusRequestResponse.swift
//  CoMap-19
//

//

import Foundation

struct StatusRequestResponse: Decodable, Hashable {
  private(set) var imageUrl: String?
  private(set) var appName: String?
  private(set) var requestId: String
  private(set) var reason: String?
  private(set) var time: String?
  private(set) var startDate: String?
  private(set) var endDate: String?
  
  private enum CodingKeys: String, CodingKey {
    case imageUrl = "img"
    case appName = "name"
    case requestId = "id"
    case reason
    case time
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(requestId)
  }
}

extension StatusRequestResponse: Equatable {
  static func == (lhs: StatusRequestResponse, rhs: StatusRequestResponse) -> Bool {
    return lhs.requestId == rhs.requestId
  }
}
