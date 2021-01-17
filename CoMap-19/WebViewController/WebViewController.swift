//
//  WebViewController.swift
//  CoMap-19
//

//
//

import Foundation
import WebKit
import SVProgressHUD

enum WebKitInteractionMethodName: String {
  case shareApp
  case getHeader
  case closeWebView
  case copyToClipboard
  case hideLoader
  case askForUpload
  case getContact
  case payUsingUpi
  case refreshWebView
}

final class WebViewController: UIViewController {
  
  // MARK: - Private variables
  
  fileprivate var webView: WKWebView?
  fileprivate var currentWebViewUrlRequest: URLRequest?
  
  // MARK: - Public Variables
  
  var urlString: String? = Constants.WebUrl.HomePage
  
  // MARK: - View Life cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if isWebViewControllerPresented() {
      let closeButton: UIBarButtonItem = UIBarButtonItem( image: #imageLiteral(resourceName: "cross_button"),
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(closeButtonPressed(sender:)))
      self.navigationItem.leftBarButtonItem = closeButton
    }
    
    addWebView()
    loadRequest()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    AnalyticsManager.setScreenName(name: ScreenName.pushNotificationScreen,
                                   className: NSStringFromClass(type(of: self)))
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    SVProgressHUD.dismiss()
    
    super.viewWillDisappear(animated)
  }
  
  deinit {
    webView?.scrollView.delegate = nil
    webView?.navigationDelegate = nil
  }
  
  // MARK: - Private methods
  
  fileprivate func isHostSwarksha(url: URL) -> Bool {
    if let homeUrlHost = URL(string: Constants.WebUrl.HomePage)?.host {
      
      return url.host?.caseInsensitiveCompare(homeUrlHost) == .orderedSame
    }
    
    return false
  }
  
  fileprivate func loadRequest() {
    
    SVProgressHUD.show()
    
    guard let urlString = urlString else {
      return
    }
    
    var urlComponents = URLComponents(string: urlString)
    
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
  
  @objc fileprivate func closeButtonPressed(sender: UIBarButtonItem) {
    if isWebViewControllerPresented() {
      dismiss(animated: true, completion: nil)
    }
    else {
      _ = navigationController?.popViewController(animated: true)
    }
  }
    
  fileprivate func addWebView() {
    let config = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    
    contentController.add(self, name: WebKitInteractionMethodName.shareApp.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.getHeader.rawValue)
    contentController.add(self, name: WebKitInteractionMethodName.closeWebView.rawValue)
    
    config.userContentController = contentController
    
    webView = WKWebView(frame: .zero, configuration: config)
    
    webView?.navigationDelegate = self
    
    if let webView = webView {
      view.addSubview(webView)
      webView.translatesAutoresizingMaskIntoConstraints = false
      
      view.addConstraints([
        NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)])
    }
    
  }
  
  fileprivate func isWebViewControllerPresented() -> Bool {
    
    // If the viewcontroller in the stack of navigation controller is not the first, then it is pushed
    if let navigationController = self.navigationController, navigationController.viewControllers.first != self {
      return false
    }
    
    if presentingViewController != nil {
      return true
    }
    else if presentingViewController?.presentedViewController == self {
      return true
    }
    else if navigationController?.presentingViewController?.presentedViewController == navigationController {
      return true
    }
    else if tabBarController?.presentingViewController is UITabBarController {
      return true
    }
    return false
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
}

// MARK: - WKNavigationDelegate methods implementations

extension WebViewController: WKNavigationDelegate {
  
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
          SVProgressHUD.show()
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
  
  func webView(_ webView: WKWebView,
               didReceive challenge: URLAuthenticationChallenge,
               completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    webView.didReceive(challenge, completionHandler: completionHandler)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if !webView.isLoading {
      self.title = webView.title
      SVProgressHUD.dismiss()
    }
    
    webView.evaluateJavaScript("getHeader", completionHandler: { (result, error) in
      //debugPrint("called")
    })
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    SVProgressHUD.dismiss()
  }
}

// MARK: - WKScriptMessageHandler methods implementations

extension WebViewController: WKScriptMessageHandler {
  func userContentController(_ userContentController: WKUserContentController,
                             didReceive message: WKScriptMessage) {
    
    let methodName = WebKitInteractionMethodName(rawValue: message.name)
    
    switch methodName {
    case .shareApp:
      let permission = Permission(viewController: self)
      permission.shareApp()
      let params = ["screenName" : "WebViewController"]
      AnalyticsManager.logEvent(name: Events.shareClicked, parameters: params)
      
    case .getHeader:
      if let url = message.webView?.url {
        webView?.evaluateJavaScript("sendHeader('\(getHeaders(url: url))')", completionHandler: nil)
      }
      
    case .closeWebView:
      if isWebViewControllerPresented() {
        dismiss(animated: true, completion: nil)
      }
      else {
        _ = navigationController?.popViewController(animated: true)
      }
      
    default:
      break
    }
  }
  
}
