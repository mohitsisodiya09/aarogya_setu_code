//
//  TncViewController.swift
//  CoMap-19
//

//
//

import UIKit
import SVProgressHUD
import WebKit

final class TncViewController: UIViewController {
  
  // MARK: - Private variables
  
  fileprivate var url: URL!
  fileprivate var webView: WKWebView?
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var crossButton: UIButton! {
    didSet {
      crossButton.accessibilityLabel = AccessibilityLabel.dismiss
    }
  }
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 16.0
    }
  }
  
  @IBOutlet weak var webContainerView: UIView!
  
  // MARK: - Initialization methods
  
  convenience init(url: URL) {
    self.init(nibName: "TncViewController", bundle: nil)
    self.url = url
    setupViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  deinit {
    SVProgressHUD.dismiss()
  }
  
  // MARK: - Private methods
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    
    addWebView()
    loadRequest()
  }
  
  fileprivate func addWebView() {
    let config = WKWebViewConfiguration()
    let contentController = WKUserContentController()
    
    
    config.userContentController = contentController
    
    webView = WKWebView(frame: .zero, configuration: config)
    
    webView?.navigationDelegate = self
    
    if let webView = webView {
      webContainerView.addSubview(webView)
      webView.translatesAutoresizingMaskIntoConstraints = false
      
      webContainerView.addConstraints([
        NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: webContainerView, attribute: .width, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: webContainerView, attribute: .height, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .centerX, relatedBy: .equal, toItem: webContainerView, attribute: .centerX, multiplier: 1.0, constant: 0),
        NSLayoutConstraint(item: webView, attribute: .centerY, relatedBy: .equal, toItem: webContainerView, attribute: .centerY, multiplier: 1.0, constant: 0)])
    }
    
  }
  
  fileprivate func loadRequest() {
    SVProgressHUD.show()
    
    guard let url = url else {
      return
    }
    
    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
    
    if let langKey = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
      let languageQueryItem = URLQueryItem(name: Constants.ApiKeys.lang,
                                           value: langKey)
      urlComponents?.queryItems = [languageQueryItem]
    }
    
    if let url = urlComponents?.url {
      var request = URLRequest(url: url)
      request.setValue(Constants.platformToken, forHTTPHeaderField: "pt")
      request.setValue(Constants.NetworkParams.version, forHTTPHeaderField: Constants.NetworkParams.versionKey)
      request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: Constants.NetworkParams.osKey)
      
      webView?.load(request)
    }
  }
  
  // MARK: - IBActions
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension TncViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }
  
}

// MARK: - WKNavigationDelegate methods

extension TncViewController: WKNavigationDelegate {
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    SVProgressHUD.dismiss()
    titleLabel.text = webView.title
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    SVProgressHUD.dismiss()
  }
}

