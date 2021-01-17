//
//  PendingRequestsResponse.swift
//  CoMap-19
//

//

import Foundation

enum PendingRequestType: Decodable {
  case pending
  case rejected
  case alwaysApproved
  case approved
  case autoApproved
  case autoRejected
  case raNotInitiated
  case raSpam
  case raOthers
  case raBlock
  case none
  
  init(from decoder: Decoder) throws {
    let screenType = try decoder.singleValueContainer().decode(String.self)
    switch screenType {
    case "PENDING":
      self = .pending
    case "REJECT":
      self = .rejected
    case "APPROVE":
      self = .approved
    case "ALWAYS_APPROVE":
      self = .alwaysApproved
    case "AUTO_APPROVE":
      self = .autoApproved
    case "AUTO_REJECT":
      self = .autoRejected
    case "RA_NOT_INITIATED":
      self = .raNotInitiated
    case "RA_SPAM":
      self = .raSpam
    case "RA_OTHERS":
      self = .raOthers
    case "RA_BLOCK":
      self = .raBlock
    default:
      self = .none
    }
  }
}

struct PendingRequest: Decodable {
  private(set) var id: String
  private(set) var createdOn: String?
  private(set) var imageUrl: String?
  private(set) var name: String?
  private(set) var requestStatus: PendingRequestType?
  private(set) var userId: String?
  private(set) var reason: String?
  private(set) var startDate: String?
  private(set) var endDate: String?
  
  private enum CodingKeys: String, CodingKey {
    case id
    case createdOn
    case imageUrl = "img"
    case name
    case requestStatus
    case userId
    case reason
    case startDate
    case endDate
  }
}
