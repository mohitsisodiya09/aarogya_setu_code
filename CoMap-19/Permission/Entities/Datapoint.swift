//
//  Datapoint.swift
//  CoMap-19
//

//
//

import Foundation

struct UserList: Codable {
  var m: String
  var d: String
  var data: [String]
}

struct Datapoint: Codable {
  var ts: String
  var l: Location
  var dl: [Device]
}

struct Location: Codable {
  var lat: Double
  var lon: Double
}

struct Device: Codable {
  var d: String
  var dist: Int
  var tx_power: String
  var tx_level: String
}

struct DataToPost: Codable {
  var m: String
  var d: String
  var data: [Datapoint]
}
