//
//  JWT.swift
//  CoMap-19
//

//
//

import SwiftJWT
import Foundation

/**
 * Json Web Token Decoding
 */

final class JWTDecoding {

  private let payload: String
  private var jwtToken: String
  
  init?(token: String) {
    let parts = token.components(separatedBy: ".")
    
    if parts.count == 3 {
      self.jwtToken = token
      self.payload = parts[1]
    }
    else {
      return nil
    }
  }

  init?(token: String, publicKey: String) {
    let parts = token.components(separatedBy: ".")
    
    if parts.count == 3 {
      self.jwtToken = token
      self.payload = parts[1]
      
      guard let publicKey: Data = publicKey.data(using: .utf8) else {
        return nil
      }
      
      let jwtVerifier: JWTVerifier = JWTVerifier.rs256(publicKey: publicKey)
      guard JWT<MyClaims>.verify(token, using: jwtVerifier) else {
        return nil
      }
    }
    else {
      return nil
    }
  }
  
  func verify(publicKey: String) -> Bool {
    guard let publicKey: Data = publicKey.data(using: .utf8) else { return false }
    
    let jwtVerifier: JWTVerifier = JWTVerifier.rs256(publicKey: publicKey)
    return JWT<MyClaims>.verify(jwtToken, using: jwtVerifier)
  }

  func payloadDict() -> [String: Any] {
    return JWTDecoding.decodeJWTPart(payload) ?? [:]
  }

  static func decodePayload(jwtToken jwt: String) -> [String: Any] {
    let segments = jwt.components(separatedBy: ".")
    return decodeJWTPart(segments[1]) ?? [:]
  }

  private static func data(base64urlEncoded: String) -> Data? {
      let paddingLength = 4 - base64urlEncoded.count % 4
      let padding = (paddingLength < 4) ? String(repeating: "=", count: paddingLength) : ""
      let base64EncodedString = base64urlEncoded
          .replacingOccurrences(of: "-", with: "+")
          .replacingOccurrences(of: "_", with: "/")
          + padding
      return Data(base64Encoded: base64EncodedString)
  }

  private static func base64UrlDecode(_ value: String) -> Data? {
    var base64 = value
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
      let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
      base64 = base64 + padding
    }
    return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
  }

  private static func decodeJWTPart(_ value: String) -> [String: Any]? {
    guard let bodyData = base64UrlDecode(value),
      let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
        return nil
    }

    return payload
  }

}
