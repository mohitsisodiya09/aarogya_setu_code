//
//  WKWebViewExtension.swift
//  CoMap-19
//

//
//

import UIKit
import Security
import CommonCrypto

class SSLPinning {
  
  static func sha4096(data : Data) -> String {
    var keyWithHeader = Data(Constants.SSLPinning.rsa4096Asn1Header)
    keyWithHeader.append(data)
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    
    keyWithHeader.withUnsafeBytes {
      _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
    }
    
    
    return Data(hash).base64EncodedString()
  }
  
  static func sha2048(data : Data) -> String {
     var keyWithHeader = Data(Constants.SSLPinning.rsa2048Asn1Header)
     keyWithHeader.append(data)
     var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
     
     keyWithHeader.withUnsafeBytes {
       _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
     }
     
     
     return Data(hash).base64EncodedString()
   }
  
  static func didReceive(_ challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
      if let serverTrust = challenge.protectionSpace.serverTrust {
        var secresult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secresult)
        
        if(errSecSuccess == status) {
          if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
          
            let serverPublicKey = SecCertificateCopyPublicKey(serverCertificate)
            let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
            
            
            if (challenge.protectionSpace.host == URL(string: Constants.authBaseUrl)?.host) {
              
              let keyHash = sha2048(data: serverPublicKeyData as Data)
              if (keyHash == Constants.SSLPinning.authenticationPublicKeyHash) {
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
              }
              else if (keyHash == Constants.SSLPinning.authenticationBackupPublicKeyHash) {
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
              }
            }
            else  {
              let keyHash = sha4096(data: serverPublicKeyData as Data)
              if (keyHash == Constants.SSLPinning.pinnedPublicKeyHash) {
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
              }
              else if(keyHash == Constants.SSLPinning.backupPinnedPublicKeyHash){
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
                return
              }
            }
          }
        }
      }
    }
    
    completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
  }
  
}
