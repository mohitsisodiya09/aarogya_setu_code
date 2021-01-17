//
//  Permission.swift
//  CoMap-19
//

//
//

import UIKit
import AVKit
import CoreBluetooth
import CoreLocation

enum PermissionType {
  case bluetooth
  case location
  case camera
  
  var description: String {
    switch self {
    case .bluetooth:
      return "Bluetooth"
    case .location:
      return "Location"
    case .camera:
      return "Camera"
    }
  }
}

enum PermissionStatus: Int, CustomStringConvertible {
  case authorized, unauthorized, unknown, disabled
  
  var description: String {
    switch self {
    case .authorized:   return "Authorized"
    case .unauthorized: return "Unauthorized"
    case .unknown:      return "Unknown"
    case .disabled:     return "Disabled"
    }
  }
}


final class Permission: NSObject {
  
  private lazy var locationManager:CLLocationManager = {
    let lm = CLLocationManager()
    lm.delegate = self
    return lm
  }()
  
  private var bleManager: CBCentralManager? = nil
  
  fileprivate var waitingForBluetooth: Bool = false
  fileprivate var askedBluetooth: Bool {
    get {
      return UserDefaults.standard.bool(forKey: "askedForBluetooth")
    } set {
      UserDefaults.standard.set(newValue, forKey: "askedForBluetooth")
    }
  }
  
  private weak var viewControllerForAlerts : UIViewController?
  
  init(viewController: UIViewController?) {
    self.viewControllerForAlerts = viewController
  }
  
  convenience override init() {
    self.init(viewController: UIApplication.topViewController())
  }
  
  // MARK: - Share App
  
  func shareApp() {
    let item = [String(format: "%@ \niOS: %@ \nAndroid: %@",
                       Localization.shareAppMessage,
                       Constants.iosUrl,
                       Constants.androidUrl)]
    let activityController = UIActivityViewController(activityItems: [item.joined(separator: Constants.StringValues.newLineCharacter)],
                                                      applicationActivities: nil)
    activityController.excludedActivityTypes = getExcludedActivities()
    self.viewControllerForAlerts?.present(activityController, animated: true, completion: nil)
  }
  
  func shareMessage(_ message: String) {
    let activityController = UIActivityViewController(activityItems: [message],
                                                      applicationActivities: nil)
    activityController.excludedActivityTypes = getExcludedActivities()
    self.viewControllerForAlerts?.present(activityController, animated: true, completion: nil)
  }
  
  fileprivate func getExcludedActivities() -> [UIActivity.ActivityType] {
    return [.print,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo]
  }
  
  // MARK: - Request Camera
  func statusCamera() -> PermissionStatus {
    let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    switch status {
    case .authorized:
      return .authorized
    case .restricted, .denied:
      return .unauthorized
    case .notDetermined:
      return .unknown
    @unknown default:
      return .disabled
    }
  }
  
  func requestCamera(_ permissionGranted: @escaping (Bool)->Void) {
    let status = statusCamera()
    switch status {
    case .unknown:
      AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { response in
        permissionGranted(response)
      })
    case .unauthorized:
      self.showDeniedAlert(.camera)
    case .disabled:
      self.showDisabledAlert(.camera)
    default:
      permissionGranted(true)
    }
  }
  
  // MARK: - Location methods
  
  func statusLocation() -> PermissionStatus {
    guard CLLocationManager.locationServicesEnabled() else { return .disabled }
    
    let status = CLLocationManager.authorizationStatus()
    switch status {
    case .authorizedAlways:
      return .authorized
    case .restricted, .denied:
      return .unauthorized
    case .authorizedWhenInUse:
      return .authorized
    case .notDetermined:
      return .unknown
    @unknown default:
      return .unknown
    }
    
  }
  
  func requestLocation() {
    let status = statusLocation()
    switch status {
    case .unknown:
      locationManager.requestAlwaysAuthorization()
    case .unauthorized:
      self.showLocationPermissionAlert()
    case .disabled:
      self.showLocationPermissionAlert()
    default:
      break
    }
  }
  
  // MARK: - Bluetooth methods
  
  private func triggerBluetoothStatusUpdate() {
    guard bleManager != nil else {
      self.bleManager = CBCentralManager(delegate: self, queue: nil)
      return
    }
    
    if !waitingForBluetooth && bleManager?.state == .unknown {
      bleManager?.scanForPeripherals(withServices: nil, options: nil)
      bleManager?.stopScan()
      askedBluetooth = true
      waitingForBluetooth = true
      UserDefaults.standard.set(true, forKey: "askedForBluetooth")
    }
  }
  
  func requestBluetooth() {
    let status = statusBluetooth()
    switch status {
    case .disabled:
      showBluetoothPermissionAlert()
    case .unauthorized:
      showBluetoothPermissionAlert()
    case .unknown:
      triggerBluetoothStatusUpdate()
    default:
      break
    }
  }
  
  
  func statusBluetooth() -> PermissionStatus {
    if askedBluetooth{
      triggerBluetoothStatusUpdate()
    } else {
      return .unknown
    }
    
    let state = (bleManager?.state, CBPeripheralManager.authorizationStatus())
    switch state {
    case (.unsupported, _), (.poweredOff, _), (_, .restricted):
        UserDefaults.standard.set(false, forKey: "isBluetoothOn")
      return .disabled
    case (.unauthorized, _), (_, .denied):
        UserDefaults.standard.set(false, forKey: "isBluetoothOn")
      return .unauthorized
    case (.poweredOn, .authorized):
      UserDefaults.standard.set(true, forKey: "isBluetoothOn")
      return .authorized
    default:
      return .unknown
    }
  }
  
  // MARK: - Alert Messages
    
    func showLocationPermissionAlert(){
        AlertView.showLocationAlert(internetConnectionLost: {
            //Open Setting for Bluetooth
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            let app = UIApplication.shared
            app.open(url)
        }) {
            //Cancel Do Nothing
        }
    }
    
    func showBluetoothPermissionAlert(){
        AlertView.showBluetoothAlert(internetConnectionLost: {
            //Open Setting for Bluetooth
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            let app = UIApplication.shared
            app.open(url)
        }) {
            //Cancel Do Nothing
        }
    }
  
  private func showDeniedAlert(_ permission: PermissionType) {
    let alert = UIAlertController(title: "Permission for \(permission.description) was denied.",
      message: "Please enable access to \(permission.description) in the Settings app",
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
                                  style: .cancel,
                                  handler: nil))
    alert.addAction(UIAlertAction(title: "Show me",
                                  style: .default,
                                  handler: { action in
                                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                                    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
    }))
    
    DispatchQueue.main.async {
      self.viewControllerForAlerts?.present(alert,
                   animated: true, completion: nil)
    }
  }
  
  private func showDisabledAlert(_ permission: PermissionType) {
    let alert = UIAlertController(title: "\(permission.description) is currently disabled.",
      message: "Please enable access to \(permission.description) in Settings",
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
                                  style: .cancel,
                                  handler: nil))
    alert.addAction(UIAlertAction(title: "Show me",
                                  style: .default,
                                  handler: { action in
                                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                                    UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
    }))
    
    DispatchQueue.main.async {
      self.viewControllerForAlerts?.present(alert,
                   animated: true, completion: nil)
    }
  }
  
}


// MARK: - CBPeripheralManagerDelegate
extension Permission: CBCentralManagerDelegate {
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    waitingForBluetooth = false
  }
  
}

// MARK: - CLLocationManagerDelegate
extension Permission: CLLocationManagerDelegate {
  
}


// MARK:- Permission Status

extension Permission {
    
    static func isLocationOn() -> Bool{
        if CLLocationManager.locationServicesEnabled() {
            return true
        }
        return false
    }
    
    static func isLocationPermissionAllowed() -> Bool{
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied,.notDetermined,.restricted:
            return false
        default:
            return true
        }
    }
    
  static func isBluetoothOn() -> Bool{
    return UserDefaults.standard.bool(forKey: Constants.UserDefault.isBluetoothOn)
  }
    
    static func isBluetoothPermissionAllowed() -> Bool{
        let status = CBPeripheralManager.authorizationStatus()
        switch status {
        case .notDetermined,.denied,.restricted:
            return false
        default:
            return true
        }
    }
}
