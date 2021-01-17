//
//  URLSessionDelegate.swift
//  CoMap-19

//
//

import Foundation

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
  
  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
    
    SSLPinning.didReceive(challenge, completionHandler: completionHandler)
  }
}
