//
//  DeleteAccountWebViewTableViewCell.swift
//  CoMap-19
//

//

import UIKit
import WebKit

class DeleteAccountWebViewTableViewCell: UITableViewCell {
  
  @IBOutlet weak var webviewContainerView: UIView!
  
  fileprivate(set) var webView: WKWebView?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    addWebView()
    selectionStyle = .none
  }
  
  // MARK: - Private methods
  
  fileprivate func addWebView() {
    
    guard webView == nil else { return }
    webView = WKWebView(frame: .zero)
    webView?.scrollView.isScrollEnabled = true
    
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
  
  // MARK: - Public methods
  
  func loadUrl(_ urlString: String) {
    if let url = URL(string: urlString) {
      webView?.load(URLRequest(url: url))
    }
  }
  
}
