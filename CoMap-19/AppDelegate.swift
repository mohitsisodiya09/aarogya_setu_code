//
//  AppDelegate.swift
//  CoMap-19
//
//
//

import UIKit
import CoreData
import Firebase
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  internal var window: UIWindow?
  
  // MARK: - Private variables
  
  fileprivate var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
  
  // MARK: - Private methods
  
  fileprivate func setDefaultValues() {
    
    if let appConfigData = UserDefaults.standard.data(forKey: Constants.UserDefault.appConfig),
       appConfigData.isEmpty == false {
      
      do {
        let appConfig = try JSONDecoder().decode(AppConfig.self, from: appConfigData)
        Constants.appConfig = appConfig
      }
      catch {
        Constants.appConfig = AppConfig()
      }
    }
    else {
      Constants.appConfig = AppConfig()
    }
  }
  
  fileprivate func getAppConfig() {
    APIClient.sharedInstance.getAppConfig { (response, error) in
      do {
        if let data = response {
          let appConfig = try JSONDecoder().decode(AppConfig.self, from: data)
          Constants.appConfig = appConfig
          
          UserDefaults.standard.set(response, forKey: Constants.UserDefault.appConfig)
          
          NotificationCenter.default.post(Notification(name: .appConfigFetched,
                                                       object: nil,
                                                       userInfo: nil))
        }
      }
      catch {
        Constants.appConfig = AppConfig()
      }
    }
  }
  
  fileprivate func performLaunchCountUpdate() {
    var launchCount = UserDefaults.standard.integer(forKey: Constants.UserDefault.numberOfLaunches)
    var launchCountForRatingPrompt = UserDefaults.standard.integer(forKey: Constants.UserDefault.launchCountForRatingPrompt)
  
    if UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
      launchCount += 1
      launchCountForRatingPrompt += 1
    }
    
    UserDefaults.standard.set(launchCount, forKey: Constants.UserDefault.numberOfLaunches)
    UserDefaults.standard.set(launchCountForRatingPrompt, forKey: Constants.UserDefault.launchCountForRatingPrompt)
  }
  
  fileprivate func registerForPushNotifications() {
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge]) {
        [weak self] granted, error in
        
        guard let self = self else {
          return
        }
        
        guard granted else {
          return
        }
        
        self.getNotificationSettings()
    }
  }
  
  
  fileprivate func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      
      guard settings.authorizationStatus == .authorized else {
        return
      }
      
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
      }
    }
  }
  
  fileprivate func registerBackgroundTask() {
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
    
    assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
  }
  
  fileprivate func endBackgroundTask() {
    //If this ends then there the BLE timer in BLECentralManager will be stopped
//    UIApplication.shared.endBackgroundTask(backgroundTask)
//    backgroundTask = UIBackgroundTaskIdentifier.invalid
  }
  
  fileprivate func persistDataInMemoryIfAvailable() {
    registerBackgroundTask()
    DAOManagerImpl.shared.saveToDisk { [weak self] (status) in
      if status == .Failure {
        printForDebug(string: "Save To Disk Failed")
      }
      self?.endBackgroundTask()
    }
  }
  
  fileprivate func deleteOldDataIfRequired() {
    if isOldDataDeleteRequired() {
      DispatchQueue.global(qos: .background).async {
        do {
          UserDefaults.standard.set(Date(), forKey: Constants.UserDefault.lastOldDataDeleteTime)
          let updateUserList = try DAOManagerImpl.shared.deleteOldData()
          DAOManagerImpl.shared.writeData(userList: updateUserList, completion: nil)
        }
        catch _ {
        }
      }
    }
  }
  
  fileprivate func isOldDataDeleteRequired() -> Bool {
    
    guard let lastRefreshDate = UserDefaults.standard.object(forKey: Constants.UserDefault.lastOldDataDeleteTime) as? Date else {
      return true
    }
    
    if let diff = Calendar.current.dateComponents([.hour], from: lastRefreshDate, to: Date()).hour, diff >= 24 {
      return true
    }
    else {
      return false
    }
  }
  
  fileprivate func fetchUserStatus() {
    
    APIClient.sharedInstance.getUserStatus { (json, urlResponse, error) in
    
      if let response = urlResponse as? HTTPURLResponse {
        if response.statusCode == 401 {
          AWSAuthentication.sharedInstance.refreshAccessToken { (success) in
            if success == true && APIClient.sharedInstance.retryCount <= 2{
              APIClient.sharedInstance.retryCount += 1
              self.fetchUserStatus()
            }
          }
          return;
        }
      }
      
      if let userResponse = json as? [String: Any] {
       
        if let status = userResponse[Constants.ApiKeys.p] as? Bool,
          status,
          let json = DAOManagerImpl.shared.getUserData() {
          
          APIClient.sharedInstance.uploadBluetoothScans(paramDict: json) { (success, error) in
            if let err = error {
              printForDebug(string: err.localizedDescription)
            }
          }
        }
        
        if let deviceId = userResponse[Constants.ApiKeys.did] as? String {
          KeychainHelper.saveDeviceId(deviceId)
        }
        
        if let qrPublicKey = userResponse[Constants.ApiKeys.qrPublicKey] as? String {
          KeychainHelper.saveQrPublicKey(qrPublicKey)
        }
      }
    }
  }
  
  fileprivate func getTopViewController() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      
      return topController
      
    }
    
    return nil
  }
  
  fileprivate func uploadBluetoothScans() {
    if let json = DAOManagerImpl.shared.getUserData() {
      APIClient.sharedInstance.uploadBluetoothScans(paramDict: json) { (success, error) in
        if let err = error {
          printForDebug(string: err.localizedDescription)
        }
      }
    }
  }
  
  // MARK: - UIApplicationDelegate methods implementation
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
    
    Localize.setup()
    
    window = UIWindow()
    window?.makeKeyAndVisible()
    window?.rootViewController = ContainerController()
    
    APIClient.sharedInstance.authorizationToken = KeychainHelper.getAwsToken()
    APIClient.sharedInstance.refreshToken = KeychainHelper.getRefreshToken()
    
    setDefaultValues()
    
    registerForPushNotifications()
    
    let params = ["screenName" : "splashScreen"]
    AnalyticsManager.logEvent(name:  ScreenName.splashScreen, parameters: params)
    
    if UserDefaults.standard.bool(forKey: Constants.UserDefault.isFirstLaunch) == false {
      AnalyticsManager.setUserProperty(value: UserProperties.first_install_time, name: Date().toString())
    }
    
    performLaunchCountUpdate()
  
    deleteOldDataIfRequired()
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    persistDataInMemoryIfAvailable()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    deleteOldDataIfRequired()
  }
    
  func applicationDidBecomeActive(_ application: UIApplication) {
    
    if APIClient.sharedInstance.authorizationToken != nil,
      UserDefaults.standard.bool(forKey: Constants.UserDefault.isUserAuthenticated) {
      StatusApprovalRequestManager.shared.fetchPendingRequests()
      fetchUserStatus()
      AWSAuthentication.sharedInstance.refreshAccessToken(completion: nil)
    }
    
    getAppConfig()
    
    RemoteConfigManager.shared.fetchRemoteConfig()
  }
  
}

extension AppDelegate: MessagingDelegate {
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    
    Messaging.messaging().shouldEstablishDirectChannel = true
    UserDefaults.standard.set(fcmToken, forKey: Constants.UserDefault.fcmToken)
   
    if APIClient.sharedInstance.authorizationToken != nil {
      APIClient.sharedInstance.sendFCMToken(fcmToken)
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    if let tag = userInfo[Constants.ApiKeys.tg] as? String, tag == "4" {
      StatusApprovalRequestManager.shared.fetchPendingRequests()
    }
    
    completionHandler(UNNotificationPresentationOptions.alert)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    
    if let target = userInfo[Constants.ApiKeys.target] as? String {
      
      let webVC = WebViewController()
      webVC.urlString = target
      let navController = UINavigationController(rootViewController: webVC)
      navController.modalPresentationStyle = .overFullScreen
      getTopViewController()?.present(navController, animated: false, completion: nil)
    }
    
    if let status = userInfo[Constants.ApiKeys.p] as? String, status == "1" {
      uploadBluetoothScans()
    }
    else if let status = userInfo[Constants.ApiKeys.pushConsent] as? String, status == "1" {
      let uploadStatusVC = UploadDataStatusViewController()
      
      if let uploadKey = userInfo[Constants.ApiKeys.uploadKey] as? String {
        uploadStatusVC.uploadKey = uploadKey
      }
      
      uploadStatusVC.sourceType = .pushConsent
      getTopViewController()?.present(uploadStatusVC, animated: true, completion: nil)
    }
    else if let tag = userInfo[Constants.ApiKeys.tg] as? String {
      if tag == "2" {
        let qrCodeVC = QRCodeViewController()
        getTopViewController()?.present(qrCodeVC, animated: true, completion: nil)
      }
      else if tag == "3" {
        let scanQrCodeVC = ScanOrCodeViewController()
        getTopViewController()?.present(scanQrCodeVC, animated: true, completion: nil)
      }
    }
    
    completionHandler()
  }
  
  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler:
    @escaping (UIBackgroundFetchResult) -> Void) {
    
    guard let aps = userInfo["aps"] as? [String: AnyObject] else {
      completionHandler(.failed)
      return
    }
    
    if aps["content-available"] as? Int == 1 {
      
      if let json = DAOManagerImpl.shared.getUserData() {
        APIClient.sharedInstance.uploadBluetoothScans(paramDict: json) { (success, error) in
          if error != nil {
            completionHandler(.failed)
          }
          else {
            completionHandler(.newData)
          }
        }
      }
      
    }
    else  {
      completionHandler(.newData)
    }
  }
}

