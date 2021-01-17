//
//  AnalyticsManager.swift
//  CoMap-19
//

//
//

import Firebase

struct Events {
  static let loginSuccess = "loginSuccess"
  static let getOtp = "getOtp"
  static let getOtpFailed = "getOtpFailed"
  static let validateOtp = "validateOtp"
  static let validateOtpFailed = "validateOtpFailed"
  static let registerWithLoc = "registerWithLoc"
  static let registerWithoutLoc = "registerWithoutLoc"
  static let shareClicked = "shareClicked"
  static let upiClicked = "upiClicked"
  static let logout = "logout"
}

struct ScreenName {
  static let splashScreen = "splashScreen"
  static let OnboardingScreen = "OnboardingScreen"
  static let infoScreen  = "infoScreen"
  static let permissionScreen = "permissionScreen"
  static let webviewScreen = "webviewScreen"
  static let languageSelectionScreen = "languageSelectionScreen"
  static let loginMobileNumberScreen = "loginMobileNumberScreen"
  static let otpVerficationScreen = "otpVerficationScreen"
  static let pushNotificationScreen = "pushNotificationScreen"
}

struct UserProperties {
  static let ga_id = "ga_id"
  static let did = "did"
  static let afid = "afid"
  static let is_loggedin = "is_loggedin"
  static let first_install_time = "first_install_time"
  static let version_code = "version_code"
  static let language = "language"
  static let last_update_time = "last_update_time"
}

class AnalyticsManager {
  
  static func logEvent(name: String, parameters: [String: Any]?) {
    Analytics.logEvent(name, parameters: parameters)
  }
  
  static func setUserProperty(value: String?, name: String) {
    Analytics.setUserProperty(value, forName: name)
  }
  
  static func setScreenName(name: String, className: String) {
    Analytics.setScreenName(name, screenClass: className)
  }
}
