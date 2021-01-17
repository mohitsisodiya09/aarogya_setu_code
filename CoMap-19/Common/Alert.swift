//
//  Alert.swift
//  CoMap-19
//

//
//

import UIKit
import StoreKit
import SystemConfiguration

typealias EmptyClosure = (() -> Void)

final class AlertView: NSObject {
  
  private var tryAgain: EmptyClosure?
  private var openSettings: EmptyClosure?
  
  private override init() {}
  
  private static let shared = AlertView()
    var isAlertPresented: Bool = false
  
  static func showAlert(internetConnectionLost tryAgain: EmptyClosure?,
                        openSettings: EmptyClosure?) {
    if AlertView.shared.isAlertPresented {
        return
    }
    let controller = ConnectionLostViewController()
    AlertView.shared.isAlertPresented = true
    shared.tryAgain = tryAgain
    shared.openSettings = openSettings
    controller.delegate = shared
    controller.sourceType = .internet
    UIApplication.topViewController()?.present(controller, animated: true, completion: nil)
  }
    
    static func showLocationAlert(internetConnectionLost tryAgain: EmptyClosure?,
                                  openSettings: EmptyClosure?) {
        if AlertView.shared.isAlertPresented {
            return
      }
      DispatchQueue.main.async {
        if let viewController = UIApplication.topViewController() {
          AlertView.shared.isAlertPresented = true
          let controller = ConnectionLostViewController()
          shared.tryAgain = tryAgain
          shared.openSettings = openSettings
          controller.delegate = shared
          controller.sourceType = .location
          viewController.present(controller, animated: true, completion: nil)
        }
      }
      
    }
    
    static func showBluetoothAlert(internetConnectionLost tryAgain: EmptyClosure?,
                                   openSettings: EmptyClosure?) {
        if AlertView.shared.isAlertPresented {
            return
        }
        DispatchQueue.main.async {
          if let topController = UIApplication.topViewController() {
            AlertView.shared.isAlertPresented = true
            let controller = ConnectionLostViewController()
            shared.tryAgain = tryAgain
            shared.openSettings = openSettings
            controller.delegate = shared
            controller.sourceType = .bluetooth
            topController.present(controller, animated: true, completion: nil)
          }
      }
    }
  
  static func internetConnected() -> Bool {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
      $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
        SCNetworkReachabilityCreateWithAddress(nil, $0)
      }
    }) else {
      return false
    }
    
    var flags: SCNetworkReachabilityFlags = []
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
      return false
    }
    
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    
    return (isReachable && !needsConnection)
  }
  
  static func showRatingConsentAlert() {
    let alertController = UIAlertController(title: nil,
                                            message: Localization.ratingTitle,
                                            preferredStyle: .alert)
    
    let notNowAction = UIAlertAction(title: Localization.notNow, style: .cancel, handler: { (action) in
      UserDefaults.standard.set(0, forKey: Constants.UserDefault.launchCountForRatingPrompt)
    })
    let rateNowAction = UIAlertAction(title: Localization.rateNow, style: .default) { (action) in
      UserDefaults.standard.set(true, forKey: Constants.UserDefault.appRatingPopUpDisplayed)
      SKStoreReviewController.requestReview()
    }
    
    alertController.addAction(notNowAction)
    alertController.addAction(rateNowAction)
    
    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
  }
  
}

// MARK: - ConnectionLostViewControllerDelegate

extension AlertView: ConnectionLostViewControllerDelegate {
  
  func tryAgainTapped() {
    self.isAlertPresented = false
    if AlertView.internetConnected() {
      UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
      if tryAgain != nil { self.tryAgain?() }
    }
  }
  
  func settingsTapped() {
    self.isAlertPresented = false
    UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
    if openSettings != nil { self.openSettings?() }
  }
  
}
