//
//  HomeScreenViewController.swift
//  CoMap-19
//

//
//

import UIKit
import WebKit
import CoreLocation
import SVProgressHUD

final class HomeScreenViewController: UIViewController {
  
  // MARK: - Private variables
  
  fileprivate var webView: WKWebView?
  private lazy var bleCentralManager = BLECentralManager()
  private lazy var blePeripheralManager = BLEPeripheralManager()
  fileprivate var currentLocation: Location?
  fileprivate var permission: Permission!
  fileprivate var locationService: LocationService!
  fileprivate var foundDevices: [Device]?
  fileprivate var currentWebViewUrlRequest: URLRequest?
  
  fileprivate lazy var persistDataQueue: DispatchQueue = {
    DispatchQueue(label: "com.comap.persistDataQueue", qos: .background)
  }()
  
  fileprivate struct Defaults {
    static let maxReadWriteCount = "max_count_read_write"
    static let maxDatapersistingDays = "max_data_persisting_days"
  }

  fileprivate var timer: Timer?

  // MARK: - Public variables
  
  var delegate: HomeScreenViewControllerDelegate?

  // MARK: - IBOutlets

  @IBOutlet fileprivate var webviewContainerView: UIView!
  
  @IBOutlet weak var toolTipLabel: UILabel! {
    didSet {
      toolTipLabel.textColor = UIColor.white
      toolTipLabel.font = UIFont(name: "AvenirNext-Medium", size: 14.0)
      toolTipLabel.text = Localization.toolTip
    }
  }
  
  @IBOutlet weak var toolTipView: TooltipView! {
    didSet {
      toolTipView.layer.cornerRadius = 8.0
    }
  }
  
  @IBOutlet weak var tooltipButton: UIButton! {
    didSet {
      tooltipButton.setImage(#imageLiteral(resourceName: "cross_button").withRenderingMode(.alwaysTemplate), for: .normal)
      tooltipButton.tintColor = UIColor.white
    }
  }
  
  @IBOutlet weak var shareAppButton: UIBarButtonItem! {
    didSet {
      shareAppButton.accessibilityLabel = AccessibilityLabel.shareApp
    }
  }
  
  @IBOutlet weak var changeLanguageButton: UIBarButtonItem! {
    didSet {
      changeLanguageButton.accessibilityLabel = AccessibilityLabel.languageChange
    }
  }
      
  // MARK: - View Life Cycle methods

  override func viewDidLoad() {
    super.viewDidLoad()
        
    generateRandomEncryptionKey()
    
    permission = Permission(viewController: self)
        
    addWebView()
    
    addNotificationObservers()
    setNavigationBarAppearance()
 
    if UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
      loadRequest()
    }
    
    setupLocationService()
    toolTipView.isHidden = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
  
     super.viewDidAppear(animated)
           
      if !UserDefaults.standard.bool(forKey: Constants.UserDefault.languageSelectionDone) {
        presentLanguageSelectionScreen()
      }
      else if UserDefaults.standard.bool(forKey: Constants.UserDefault.isFirstLaunch) == false {
        presentOnboardingScreen()
      }
      else if UserDefaults.standard.bool(forKey: Constants.UserDefault.isUserAuthenticated) == false {
        presentLoginScreen()
     }
   
      if UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
       configureBLE()
       showToolTipIfApplicable()
     }
     
     showAppRatingPopUp()
     
     AnalyticsManager.setScreenName(name: ScreenName.webviewScreen,
                                    className: NSStringFromClass(type(of: self)))
     
   }
  
  // MARK: - Private methods
  
  fileprivate func presentLanguageSelectionScreen() {
    let storyboard = UIStoryboard(name: Constants.Storyboard.languageSelection, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.languageSelection)
    
    let navController = UINavigationController(rootViewController: controller)
    navController.modalPresentationStyle = .overFullScreen
    self.present(navController, animated: false, completion: nil)
  }
  
  fileprivate func presentOnboardingScreen() {
    let storyboard = UIStoryboard(name: Constants.Storyboard.onboarding, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.onboarding)
    
    let navController = UINavigationController(rootViewController: controller)
    navController.modalPresentationStyle = .overFullScreen
    self.present(navController, animated: false, completion: nil)
  }
  
  fileprivate func presentLoginScreen() {
    let loginVC = LoginViewController()
    loginVC.shouldHideCloseButton = true
    self.present(loginVC, animated: true, completion: nil)
  }
  
  fileprivate func generateRandomEncryptionKey() {
    DispatchQueue.global(qos: .background).async {
      if (KeychainHelper.getConvertingKey() == nil) {
        KeychainHelper.saveConvertingKey(ConvertingLogic.generateRandom32BitKey())
      }
    }
  }
  
  fileprivate func shouldShowToolTip() -> Bool {
    return UserDefaults.standard.integer(forKey: Constants.UserDefault.numberOfLaunches) <= Constants.maxToolTipVisibleCount &&
      UserDefaults.standard.bool(forKey: Constants.UserDefault.isToolTipCancelled) == false
  }
  
  fileprivate func showToolTipIfApplicable() {
    if shouldShowToolTip() {
      toolTipView.isHidden = false
      
      timer = Timer.scheduledTimer(withTimeInterval: Constants.toolTipVisibleDuration,
                                   repeats: false,
                                   block: { [weak self] (timer) in
                                    self?.toolTipView.isHidden = true
      })
    }
    else {
      toolTipView.isHidden = true
    }
  }
  
  fileprivate func setNavigationBarAppearance() {
    self.navigationItem.leftBarButtonItem = nil
    
    self.navigationController?.navigationBar.isTranslucent = false
    self.navigationController?.navigationBar.barTintColor = UIColor.white
  }
  
  fileprivate func addNotificationObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.userLoggedIn),
                                           name: .login,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.appConfigFetched),
                                           name: .appConfigFetched,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(self.userLoggedOut),
                                           name: .logout,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector:#selector(appMovedToForeground),
                                           name: UIApplication.willEnterForegroundNotification,
                                           object: nil)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(configureBLE),
                                           name: .deviceIdSaved,
                                           object: nil)
  }
  
  @objc fileprivate func appMovedToForeground() {
    if UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
      if let request = currentWebViewUrlRequest {
        webView?.load(request)
      }
      else {
        loadRequest()
      }
    }
  }
  
  fileprivate func setupLocationService() {
    if UserDefaults.standard.bool(forKey: "isUserAuthenticated") {
      let locationStatus = permission.statusLocation()
      if locationStatus == .authorized {
        locationService = LocationService()
        locationService.setupLocationService()
        locationService.startUpdatingLocation()
        locationService?.delegate = self
      }
      else {
        permission.requestLocation()
      }
    }
  }
  
  fileprivate func addBackBarButtonItem() {
    self.navigationItem.setLeftBarButtonItems([backButtonBarItem()], animated: false)
  }
  
  fileprivate func addMenuBarButtonItem() -> UIBarButtonItem {
    let menuIconView = MenuIconView()
    let requestCount = StatusApprovalRequestManager.shared.pendingRequests.unique().count
    menuIconView.configure(shouldShowDot: requestCount > 0 ? true : false)
    let viewGestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(menuBarButtonTapped(_:)))
    menuIconView.addGestureRecognizer(viewGestureRecognizer)
    return UIBarButtonItem(customView: menuIconView)
  }

  fileprivate func backButtonBarItem() -> UIBarButtonItem {
    let button = UIBarButtonItem(image: #imageLiteral(resourceName: "back_gray"),
                                 style: .plain,
                                 target: self,
                                 action: #selector(backButtonTapped))
    button.accessibilityLabel = AccessibilityLabel.back
    return button
  }
  
  fileprivate func showForceUpgradeAlertIfApplicable() {
    
    guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
      return
    }
    
    if let specificVersions = Constants.appConfig?.forceUpgrade?.specificVersion,
      specificVersions.isEmpty == false {
      
      if specificVersions.first(where: { $0.compare(currentVersion, options: .numeric) == .orderedSame }) != nil {
        showForceUpgrade()
      }
    }
    
    if let minVersion = Constants.appConfig?.forceUpgrade?.minVersion {
      if minVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
        showForceUpgrade()
      }
    }
  }
  
  fileprivate func showForceUpgrade() {
    var message: String?
    
    if let displayName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
      message = String(format: Localization.pleaseDownloadLatestVersion, displayName)
    }
    
    let otherAlert = UIAlertController(title: Localization.pleaseUpgrade, message: message, preferredStyle: .alert)
    
    let upgrade = UIAlertAction(title: "Upgrade", style: .default) { (action) in
      
      if let url = URL(string: Constants.iosUrl) {
        if UIApplication.shared.canOpenURL(url) == true  {
          UIApplication.shared.open(url)
        }
      }
    }
    
    otherAlert.addAction(upgrade)
    
    DispatchQueue.main.async {
      if self.presentedViewController != nil  {
        self.presentedViewController?.present(otherAlert, animated: true, completion: nil)
      }
      else {
        self.present(otherAlert, animated: true, completion: nil)
      }
    }
  }
  
  @objc fileprivate func backButtonTapped() {
    loadRequest()
  }
  
  @objc fileprivate func userLoggedIn(notification: NSNotification) {    
    setupLocationService()
    loadRequest()
    trackLoginInEvents(isLoggedIn: true)
  
    let params = ["screenName" : "OtpVerificationViewController"]
    AnalyticsManager.logEvent(name: Events.loginSuccess, parameters: params)
    
    showToolTipIfApplicable()
  }
    
  @objc fileprivate func userLoggedOut(notification: NSNotification) {
    
    let storyboard = UIStoryboard(name: Constants.Storyboard.main, bundle: nil)
   
    if let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.permissionScreen) as? PermissionScreenViewController {
      controller.shouldPresentLoginScreen = true
      let navController = UINavigationController(rootViewController: controller)
      navController.modalPresentationStyle = .fullScreen
      self.present(navController, animated: false, completion: nil)
    }
    
    SVProgressHUD.dismiss()
    
    trackLoginInEvents(isLoggedIn: false)
    AnalyticsManager.logEvent(name: Events.logout, parameters: nil)
  }
  
  fileprivate func trackLoginInEvents(isLoggedIn: Bool) {
    AnalyticsManager.setUserProperty(value: KeychainHelper.getDeviceId(), name: UserProperties.did)
    AnalyticsManager.setUserProperty(value: isLoggedIn ? "true" : "false", name: UserProperties.is_loggedin)
    
    let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    AnalyticsManager.setUserProperty(value: appVersion, name: UserProperties.version_code)
        
    let lang = UserDefaults.standard.string(forKey: Constants.UserDefault.selectedLanguageKey)
    AnalyticsManager.setUserProperty(value: lang, name: UserProperties.language)
  }
  
  @objc fileprivate func appConfigFetched(notification: NSNotification) {
    showForceUpgradeAlertIfApplicable()
  }
  
  fileprivate func showAppRatingPopUp() {
    let launchCountForRating: Int = RemoteConfigManager.shared.getIntValueFor(key: RemoteConfigKeys.launchCountForRating) ?? RemoteConfigDefaults.launchCountForRating
    let numberOfAppLaunches: Int = UserDefaults.standard.integer(forKey: Constants.UserDefault.launchCountForRatingPrompt)
    
    if UserDefaults.standard.bool(forKey: "isUserAuthenticated") &&
      !UserDefaults.standard.bool(forKey: Constants.UserDefault.appRatingPopUpDisplayed) &&
      launchCountForRating <= numberOfAppLaunches {
      
      AlertView.showRatingConsentAlert()
    }
  }
  
  @objc fileprivate func configureBLE() {
    bleCentralManager.delegate = self
    if let deviceIdentifier = KeychainHelper.getDeviceId(), !deviceIdentifier.isEmpty{
      _ = blePeripheralManager
    }
  }

  @objc fileprivate func menuBarButtonTapped(_ sender: UIBarButtonItem) {
    toolTipView.isHidden = true
    UserDefaults.standard.set(true, forKey: Constants.UserDefault.isToolTipCancelled)
    delegate?.homeScreenViewController(self, menuButtonTapped: sender)
  }
  
  fileprivate func addWebView() {
    let config = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    
    contentController.add(self, name: WebKitInteractionMethodName.payUsingUpi.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.shareApp.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.getHeader.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.copyToClipboard.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.hideLoader.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.askForUpload.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.getContact.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.refreshWebView.rawValue)
    
    config.userContentController = contentController
    
    webView = WKWebView(frame: .zero, configuration: config)
    
    webView?.navigationDelegate = self
    webView?.allowsLinkPreview = false
    
    if let webView = webView {
      webviewContainerView.addSubview(webView)
      webView.translatesAutoresizingMaskIntoConstraints = false
      
      webviewContainerView.addConstraints([
        NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: webviewContainerView, attribute: .width, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: webviewContainerView, attribute: .height, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .centerX, relatedBy: .equal, toItem: webviewContainerView, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .centerY, relatedBy: .equal, toItem: webviewContainerView, attribute: .centerY, multiplier: 1.0, constant: 0)])
    }

  }
  
  fileprivate func loadRequest() {
    
    SVProgressHUD.show()
    
    var urlComponents = URLComponents(string: Constants.WebUrl.HomePage)
    
    if let langKey = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
      let languageQueryItem = URLQueryItem(name: Constants.ApiKeys.lang,
                                           value: langKey)
      urlComponents?.queryItems = [languageQueryItem]
    }
    
    if let url = urlComponents?.url {
      var request = URLRequest(url: url)
      
      if isHostSwarksha(url: url) {
        request.setValue(APIClient.sharedInstance.authorizationToken,
                         forHTTPHeaderField: Constants.ApiKeys.authorization)
      }
      
      request.setValue(Constants.platformToken, forHTTPHeaderField: "pt")
      request.setValue(Constants.NetworkParams.version, forHTTPHeaderField: Constants.NetworkParams.versionKey)
      request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: Constants.NetworkParams.osKey)
      request.setValue(APIClient.deviceModelDescription(), forHTTPHeaderField: Constants.NetworkParams.deviceModelKey)

      webView?.load(request)
    }
  }
  
  fileprivate func isHostSwarksha(url: URL) -> Bool {
     if let homeUrlHost = URL(string: Constants.WebUrl.HomePage)?.host {
       
       return url.host?.caseInsensitiveCompare(homeUrlHost) == .orderedSame
     }
    
    return false
  }
  
  fileprivate func getUniqueBluetoothContacts() -> Int {
    return DAOManagerImpl.shared.getUniqueContactCount()
  }
  
  fileprivate func getHeaders(url: URL) -> [String: String] {
    var headers = [String: String]()
    
    if isHostSwarksha(url: url) {
      if let token = APIClient.sharedInstance.authorizationToken {
        headers[Constants.ApiKeys.authorization] = token
      }
      
      if let deviceId = KeychainHelper.getDeviceId() {
        headers[Constants.ApiKeys.did] = deviceId
      }
      
      let location = DAOManagerImpl.shared.currentLocation
      var latitude, longitude: String?
      if let lat = location?.lat {
        latitude = String(format: "%f", lat)
        headers[Constants.NetworkParams.lat] = latitude
      }
      if let long = location?.lon {
        longitude = String(format: "%f", long)
        headers[Constants.NetworkParams.lon] = longitude
      }
    }
    
    headers["pt"] = Constants.platformToken
    headers[Constants.NetworkParams.versionKey] = Constants.NetworkParams.version
    headers[Constants.NetworkParams.osKey] = UIDevice.current.systemVersion
    headers[Constants.NetworkParams.deviceModelKey] = APIClient.deviceModelDescription()
    headers[Constants.NetworkParams.verName] = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    return headers
    
  }
   
  fileprivate func loadRequestWithRefreshToken() {
    AWSAuthentication.sharedInstance.refreshAccessToken { [weak self] (success) in
      if success {
        if var request = self?.currentWebViewUrlRequest {
          request.setValue(APIClient.sharedInstance.authorizationToken,
                           forHTTPHeaderField: Constants.ApiKeys.authorization)
          self?.webView?.load(request)
        }
        else {
          self?.loadRequest()
        }
      }
    }
  }
  
  fileprivate func shareBluetoothData() {
    pushUploadStatusVC(sourceType: .selfConsent)
  }
  
  fileprivate func pushUploadStatusVC(sourceType: UploadDataStatusSourceType) {
    let uploadStatusVC = UploadDataStatusViewController()
    uploadStatusVC.sourceType = sourceType
    self.present(uploadStatusVC, animated: true, completion: nil)
  }
  
  // MARK: - Button Action
  
  @IBAction func changeLanguageButtonTapped(_ sender: UIBarButtonItem) {
    let storyboard = UIStoryboard(name: Constants.Storyboard.languageSelection, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.languageSelection)
    (controller as? LanguageSelectionViewController)?.delegate = self
    self.present(controller, animated: true, completion: nil)
  }
  
  @IBAction func toolTipCancelButtonTapped(_ sender: UIButton) {
    toolTipView.isHidden = true
    UserDefaults.standard.set(true, forKey: Constants.UserDefault.isToolTipCancelled)
  }
  
  @IBAction func shareAppButtonTappped(_ sender: UIBarButtonItem) {
    permission.shareApp()
    
    let params = ["screenName" : "HomeScreenViewController"]
    AnalyticsManager.logEvent(name: Events.shareClicked, parameters: params)
  }
}

// MARK: - BLECentralManagerScannerDelegate methods implementations

extension HomeScreenViewController: BLECentralManagerScannerDelegate {
 
  func didDiscoverNearbyDevices(identifier: String, rssi: NSNumber, txPower: String, platform: String) {
    debugPrint("\(Date())-\(identifier)-\(rssi)-\(txPower)-\(platform)")
    if let location = currentLocation {
      if let foundDevices = foundDevices,
        foundDevices.isEmpty == false {
        for device in foundDevices {
          persistDataQueue.sync {
            let rssi = Double(device.dist)
            DAOManagerImpl.shared.persist(identifier: device.d,
                                          rssi: NSNumber(floatLiteral: rssi),
                                          txPower: txPower,
                                          location: location)
          }
        }
        self.foundDevices = nil
      }
      // TODO: Change default platform
      persistDataQueue.sync {
        DAOManagerImpl.shared.persist(identifier: identifier, rssi: rssi, txPower: txPower, location: location)
      }
    }
    else {
      if foundDevices == nil {
        foundDevices = [Device(d: identifier, dist: rssi.intValue, tx_power: txPower, tx_level: "")]
      }
      else {
        foundDevices?.append(Device(d: identifier, dist: rssi.intValue, tx_power: txPower, tx_level: ""))
      }
    }
  }
  
}

// MARK: - LocationServiceDelegate methods implementations

extension HomeScreenViewController: LocationServiceDelegate {

  func locationService(_ locationService: LocationService, didUpdateLocation location: CLLocation) {
    
    currentLocation = Location(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    
    DAOManagerImpl.shared.currentLocation = currentLocation
    if let location = currentLocation {
      persistDataQueue.sync {
        DAOManagerImpl.shared.persistLocation(location: location)
      }
    }
  }
  
  func locationService(_ locationService: LocationService, didFailWithError error: Error) {
   // do nothing
  }
}

// MARK: - WKScriptMessageHandler methods implementations

extension HomeScreenViewController: WKScriptMessageHandler {

  func userContentController(_ userContentController: WKUserContentController,
                             didReceive message: WKScriptMessage) {
    
    let methodName = WebKitInteractionMethodName(rawValue: message.name)
    
    switch methodName {
    case .shareApp:
      permission.shareApp()
      let params = ["screenName" : "HomeScreenViewController"]
      AnalyticsManager.logEvent(name: Events.shareClicked, parameters: params)
      
    case .getHeader:
      if let url = message.webView?.url {
        webView?.evaluateJavaScript("sendHeader('\(getHeaders(url: url))')", completionHandler: nil)
      }
      
    case .copyToClipboard:
      let params = message.body as? String
      UIPasteboard.general.string = params
      
    case .hideLoader:
      SVProgressHUD.dismiss()
      
    case .askForUpload:
      shareBluetoothData()
      
    case .getContact:
      webView?.evaluateJavaScript("sendContact('\(getUniqueBluetoothContacts())')", completionHandler: nil)
     
    case .payUsingUpi:
      let params = message.body as? String ?? ""
      self.openUPIList(params: params)
      
    case .refreshWebView:
      loadRequest()
      
    default:
      break
    }
  }
}

extension HomeScreenViewController: WKNavigationDelegate {

  func webView(_ webView: WKWebView,
               didReceive challenge: URLAuthenticationChallenge,
               completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    webView.didReceive(challenge, completionHandler: completionHandler)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if !webView.isLoading {
      self.title = webView.title
      webView.scrollView.delegate = self
      SVProgressHUD.dismiss()
    }
    
    webView.evaluateJavaScript("getHeader", completionHandler: { (result, error) in
      //debugPrint("called")
    })
    
    webView.evaluateJavaScript("payUsingUpi", completionHandler: { (result, error) in
      debugPrint("payUsingUpi called")
    })
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    SVProgressHUD.dismiss()
   }
  
  func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    
    if let response = navigationResponse.response as? HTTPURLResponse {
      if response.statusCode == 401 {
        loadRequestWithRefreshToken()
        decisionHandler(.cancel)
        return
      }
    }
    
     decisionHandler(.allow)
  }
  
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
    guard let url = navigationAction.request.url else {
      decisionHandler(.allow)
      return
    }
    
    if !AlertView.internetConnected() {
      decisionHandler(.cancel)
      
      AlertView.showAlert(internetConnectionLost: { [weak self] in
        // Try Again
        if let request = self?.currentWebViewUrlRequest {
          webView.load(request)
        }
        else {
          self?.loadRequest()
        }
        }, openSettings: {
          if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
          }
      })
      
      return
    }
    
    if url.scheme == "tel", UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
      decisionHandler(.cancel)
      return
    }
  
    guard let host = url.host else {
      decisionHandler(.allow)
      return
    }
    
    let filteredStrings = Constants.WebUrl.whiteListURLs.filter({(item: String) -> Bool in
      
      let stringMatch = host.range(of: item, options: .caseInsensitive)
      return stringMatch != nil ? true : false
    })
    
    if filteredStrings.isEmpty == true, UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
      decisionHandler(.cancel)
      return
    }
    else {
      if navigationAction.request.value(forHTTPHeaderField: "Authorization") == nil &&
        host.contains("youtube") == false {
        addBackBarButtonItem()
      }
      else {
        self.navigationItem.leftBarButtonItem = addMenuBarButtonItem()
      }
      
      guard let homeUrlHost = URL(string: Constants.WebUrl.HomePage)?.host else {
        decisionHandler(.allow)
        return
      }
      
      if host.caseInsensitiveCompare(homeUrlHost) == .orderedSame {
        
        if navigationAction.request.value(forHTTPHeaderField: "Authorization") != nil ||
          navigationAction.request.value(forHTTPHeaderField: "did") != nil {
          
          currentWebViewUrlRequest = navigationAction.request
          decisionHandler(.allow)
          return
        }
        else if let deviceId = KeychainHelper.getDeviceId() {
          
          decisionHandler(.cancel)
          
          var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
          
          if let langKey = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
            let languageQueryItem = URLQueryItem(name: Constants.ApiKeys.lang,
                                                 value: langKey)
            urlComponents?.queryItems = [languageQueryItem]
          }
          
          var urlRequest = URLRequest(url: url)
          urlRequest.setValue(deviceId, forHTTPHeaderField: Constants.ApiKeys.did)
          currentWebViewUrlRequest = urlRequest
          webView.load(urlRequest)
        }
        else {
           currentWebViewUrlRequest = navigationAction.request
          decisionHandler(.allow)
          return
        }
        
      }
      else {
        decisionHandler(.allow)
        return
      }
    }
  }
    
}

// MARK: - LanguageSelectionDelegate methods implementations

extension HomeScreenViewController: LanguageSelectionDelegate {
  
  func selectedLangauge(lang code: String) {
    if let urlRequest = currentWebViewUrlRequest, let url = urlRequest.url {
      
      var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
      urlComponents?.query = nil
      let languageQueryItem = URLQueryItem(name: Constants.ApiKeys.lang, value: code)
      urlComponents?.queryItems = [languageQueryItem]
      
      guard let url = urlComponents?.url else {
        return
      }
      
      var request = URLRequest(url: url)
      
      if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
        for header in allHTTPHeaderFields {
          request.setValue(header.value, forHTTPHeaderField: header.key)
        }
      }
      
      SVProgressHUD.show()
      request.setValue(KeychainHelper.getDeviceId(), forHTTPHeaderField: Constants.ApiKeys.did)
      webView?.load(request)
    }
    else {
      loadRequest()
    }
  }
  
}

// MARK: - UIScrollViewDelegate methods implementations

extension HomeScreenViewController: UIScrollViewDelegate {  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y > 0.0 {
      webView?.scrollView.delegate = nil
    }
  }
}

//MARK:- UPI Handling

extension HomeScreenViewController {

  fileprivate func getAvailableUPIIntent() -> [[String:String]]{
    var availableUPIIntents = [[String:String]]()
    let intents = Constants.upiIntents
    for intent in intents{
      if let intentname = intent["intent"] {
        if let url = URL(string: intentname), UIApplication.shared.canOpenURL(url) {
          availableUPIIntents.append(intent)
        }
      }
    }
    return availableUPIIntents
  }


  fileprivate func openUPIList(params: String){

    let intents  = getAvailableUPIIntent()

    let alertController = UIAlertController(title: "Pay with", message: "", preferredStyle: .actionSheet)

    for intent in intents {
      let action = UIAlertAction(title: intent["name"], style: .default) { (action:UIAlertAction) in
        if let title = action.title {
          self.clickedOnUPI(title: title, intents:intents, params: params)
        }
      }
      alertController.addAction(action)
    }

    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
      (alertAction: UIAlertAction!) in
      alertController.dismiss(animated: true, completion: nil)
    }))

    self.present(alertController, animated: true, completion: nil)

    let params = ["screenName" : "HomeScreenViewController"]
    AnalyticsManager.logEvent(name: Events.upiClicked, parameters: params)
  }

  fileprivate func alertControllerBackgroundTapped() {
    self.dismiss(animated: true, completion: nil)
  }

  fileprivate func clickedOnUPI(title:String, intents:[[String:String]], params: String) {
    for intent in intents {
      if title == intent["name"] {
        openUPIApp(intent: intent["intent"], params: params)
        break;
      }
    }
  }

  fileprivate func openUPIApp(intent: String?, params: String){


    //upi://pay?pa=goibibo.payu@axisbank&pn=Ibibo&tr=10140150899&am=1522&cu=INR&mc=5411
    guard var intentName = intent else {
      return
    }

    intentName = intentName + params

    if  let url = URL(string: intentName) {
      if UIApplication.shared.canOpenURL(url) == true  {
        UIApplication.shared.open(url)
      }
      else{
        debugPrint("Can not open application")
      }
    }
  }
}
