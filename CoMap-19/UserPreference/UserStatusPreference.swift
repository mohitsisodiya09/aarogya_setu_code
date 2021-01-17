//
//  UserStatusPreference.swift
//  CoMap-19
//
//

import Foundation

enum UserStatusPreferenceType: Decodable {
  case alwaysApprove
  case alwaysAsk
  case block
  
  init(from decoder: Decoder) throws {
    let screenType = try decoder.singleValueContainer().decode(String.self)
    switch screenType {
    case "ALWAYS_APPROVE":
      self = .alwaysApprove
    case "ALWAYS_ASK":
      self = .alwaysAsk
    case "BLOCK":
      self = .block
    default:
      self = .alwaysAsk
    }
  }
}

struct UserStatusPreference: Decodable {
  private(set) var serviceProviderId: String?
  private(set) var name: String?
  private(set) var imageUrl: String?
  private(set) var type: UserStatusPreferenceType?
  private(set) var isUser: Bool?

  fileprivate enum CodingKeys: String, CodingKey {
    case serviceProviderId, name, imageUrl = "img", type = "preference", isUser
  }
}
