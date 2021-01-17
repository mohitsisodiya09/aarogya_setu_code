//
//  DataExtension.swift
//  CoMap-19
//

//
//

import Foundation

extension Data {
  mutating func appendString(_ string: String) {
    let data = string.data(
      using: String.Encoding.utf8,
      allowLossyConversion: true)
    append(data!)
  }
}
