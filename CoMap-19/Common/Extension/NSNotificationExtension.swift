//
//  NSNotificationExtension.swift
//  CoMap-19
//

//
//

import Foundation

extension Notification.Name {
  static let login = Notification.Name("com.notification.login")
  static let appConfigFetched = Notification.Name("com.notification.appConfigFetched")
  static let logout = Notification.Name("com.notification.logout")
  static let deviceIdSaved = Notification.Name("com.notification.deviceIdSaved")
  static let languageChanged = Notification.Name("com.notification.languageChanged")
  static let nameSaved = Notification.Name("com.notification.nameSaved")
  static let requestStatusChanged = Notification.Name("com.notification.statusRequestChanged")
}
