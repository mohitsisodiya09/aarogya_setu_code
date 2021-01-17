//
//  Constants.swift
//  CoMap-19

//
//

import Foundation

struct Constants {
  
  struct ApiKeys {
    static let lang = "lang"
    static let authorization = "Authorization"
    static let specificVersion = "specific_version"
    static let minVersion = "min_version"
    static let did = "did"
    static let phoneNumber = "phone_number"
    static let primaryIdMobile = "primaryId"
    static let passCodeKey = "passcode"
    static let qrPublicKey = "qr_public_key"
    static let pushConsent = "push_consent"
    static let uploadKey = "uploadKey"
    static let p = "p"
    static let target = "target"
    static let tg = "tg"
    static let requestStatus = "request_status"
    static let error = "error"
    static let success = "success"
    static let message = "message"
    static let data = "data"
    static let serviceProviderId = "service_provider_id"
    static let preference = "preference"
    static let id = "id"
    static let token = "token"
    static let mobileNumber = "mobile_no"
    static let isUser = "is_user"
  }
  
  struct UserDefault {
    static let languageSelectionDone: String = "languageSelectionDone"
    static let onboardingOpenned: String = "onboardingOpenned"
    static let fcmToken: String = "FCMToken"
    static let selectedLanguageKey = "selectedLanguageKey"
    static let appConfig = "appConfig"
    static let isFirstLaunch = "isFirstLaunch"
    static let isBluetoothOn = "isBluetoothOn"
    static let isUserAuthenticated = "isUserAuthenticated"
    static let lastOldDataDeleteTime = "lastOldDataDeleteTime"
    static let numberOfLaunches = "numberOfLaunches"
    static let launchCountForRatingPrompt = "numberOfLaunchesForRatingPrompt"
    static let appRatingPopUpDisplayed = "appRatingPopUpDisplayed"
    static let isToolTipCancelled = "isToolTipCancelled"
  }
  
  struct Keychain {
    static let convertingKey = "com.comap.comvertingKey"
    static let deviceId = "com.comap.deviceId"
    static let awsToken = "com.comap.awsToken"
    static let refreshToken = "com.comap.refreshToken"
    static let qrPublicKey = "com.comap.qrPublicKey"
    static let name = "com.comap.name"
    static let qrMetaData = "com.comap.qrMetaData"
    static let mobileNumber = "com.comap.mobileNumber"
  }
  
  struct Storyboard {
    static let onboarding: String = "Onboarding"
    static let languageSelection: String = "LanguageSelection"
    static let main: String = "Main"
  }
  
  static let iosUrl: String = "https://apps.apple.com/in/app/aarogyasetu/id1505825357"
  
  static let androidUrl: String = "https://play.google.com/store/apps/details?id=nic.goi.aarogyasetu"
  
  static let telephoneHelplineURL: String = "tel:1075"

  static let kCommaWhitespace = ", "
  
  static let maxToolTipVisibleCount = 3
  
  static let toolTipVisibleDuration: TimeInterval = 20
  
  // File Extentions
  struct FileExtensions {
    static let json = "json"
  }
  
  struct NumericValues {
    static let zero = 0
  }
  
  struct StringValues {
    static let emptyString = ""
    static let newLineCharacter = "\n"
    static let breakCharacter = "<br>"
    static let colonWhitespace = ": "
    static let colon = ":"
    static let whitespace = " "
    static let commaWhitespace = ", "
    static let comma = ","
    static let underscore = "_"
    static let hyphen = "-"
    static let plus = "+"
    static let fullstop = "."
    static let nonBreakableSpaceUnicodeCharacter = "\u{00A0}"
  }
  
  static let PUBLIC_KEY_KEYCHAIN_TAG = "com.covid.publicKey"
  
  struct KeychainConfiguration {
    static let serviceName = "CoMap"
    static let accessGroup: String? = nil
  }
  
  static let maxDataPersistingDays = 30
  
  struct WebUrl {

    static var HomePage: String {
      guard let webUrl = infoDict[BundleKeys.webUrl] as? String else {
        fatalError("WEB_URL not found")
      }
      return webUrl
    }
    
    static var tncPage: String {
      guard let webUrl = infoDict[BundleKeys.staticWebUrl] as? String else {
        fatalError("WEB_URL not found")
      }
      return String(format: "%@%@", webUrl,"tnc/")
    }
    
    static var privacyPage: String {
      guard let webUrl = infoDict[BundleKeys.webUrl] as? String else {
        fatalError("WEB_URL not found")
      }
      return String(format: "%@%@", webUrl,"privacy/")
    }
    
    static var whiteListURLs: [String] {
      var urls = ["youtube.com"]
      
      if let webBaseUrl = infoDict[BundleKeys.webBaseUrl] as? String {
        urls.append(webBaseUrl)
      }
      
      return urls
      
    }
    
    static var deleteUrl: String {
      guard let webUrl = infoDict[BundleKeys.deleteUrl] as? String else {
        fatalError("WEB_URL not found")
      }
      return webUrl
    }
  }
  
  struct NetworkParams {
    static let httpMethodPost = "POST"
    static let httpMethodGet = "GET"
    static let httpMethodDelete = "DELETE"
    static let version = "26"
    static let versionKey = "ver"
    static let authorizationKey = "Authorization"
    static let refreshTokenKey = "refreshToken"
    static let osKey = "os"
    static let langKey = "lang"
    static let lat = "lat"
    static let lon = "lon"
    static let deviceModelKey = "device-type"
    static var baseUrl: String {
      guard let baseUrl = infoDict[BundleKeys.baseUrl] as? String else {
        fatalError("BASE_URL not found")
      }
      return baseUrl
    }
  
    static let apiKey = "x-api-key"
    static let acceptEncoding = "Accept-Encoding"
    static let verName = "ver-name"
  }

  static var appConfig: AppConfig?
   
  struct BundleKeys {
    static let baseUrl = "BASE_URL"
    static let webUrl = "WEB_URL"
    static let webBaseUrl = "WEB_BASE_URL"
    static let staticWebUrl = "STATIC_WEB_URL"
    static let sslPinningEnabled = "SSL_PINNING_ENABLED"
    static let deleteUrl = "DELETE_URL"
  }
  
  static var infoDict: [String: Any] {
    if let dict = Bundle.main.infoDictionary {
      return dict
    } else {
      return [:]
    }
  }

  struct ViewControllerIdentifer {
    static let languageSelection = "LanguageSelectionViewController"
    static let homeScreen = "HomeScreenViewController"
    static let menu = "MenuController"
    static let onboarding = "OnboardingViewController"
    static let permissionScreen = "PermissionScreenViewController"
    static let settingsScreen = "SettingsViewController"
  }
}

func printForDebug(string: String) {
  #if DEBUG
  debugPrint(string)
  #endif
}
