//
//  WKWebViewExtension.swift
//  CoMap-19
//

//
//

import UIKit
import WebKit

extension WKWebView {
  
  func didReceive(_ challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    
    guard let url = URL(string: Constants.WebUrl.HomePage) else {
      completionHandler(.performDefaultHandling, nil)
      return
    }
    
    if challenge.protectionSpace.host == url.host {
      if Constants.SSLPinning.enabled {
        SSLPinning.didReceive(challenge, completionHandler: completionHandler)
      }
      else {
        completionHandler(.performDefaultHandling, nil)
      }
    }
    else {
      completionHandler(.performDefaultHandling, nil)
    }
  }
}
