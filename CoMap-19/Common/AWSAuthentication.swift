//
//  AWSAuthentication.swift
//  CoMap-19
//

//
//

import Foundation

class AWSAuthentication {
  private init() {}
  
  static let sharedInstance = AWSAuthentication()
  
  func refreshAccessToken(completion: ((_ success: Bool) -> Void)?){
    APIClient.sharedInstance.refreshToken { (json, response, error) in
      if let dict = json as? [String:Any],
        let accessToken = dict["auth_token"] as? String,
        let refreshToken = dict["refresh_token"] as? String,
        accessToken.isEmpty == false, refreshToken.isEmpty == false{
        KeychainHelper.saveAwsToken(accessToken)
        KeychainHelper.saveRefreshToken(refreshToken)
        
        APIClient.sharedInstance.authorizationToken = accessToken
        APIClient.sharedInstance.refreshToken = refreshToken
        completion?(true)
      }
      else if let response = response as? HTTPURLResponse, response.statusCode == 401{
        DispatchQueue.main.async {
          self.signOutUserIfLoggedIn()
          completion?(false)
        }
      }
    }
  }
  
   func signOutUserIfLoggedIn(){
    if let _ = APIClient.sharedInstance.authorizationToken {
    
      KeychainHelper.removeAwsToken()
      KeychainHelper.removeRefreshToken()
      
      APIClient.sharedInstance.authorizationToken = nil
      APIClient.sharedInstance.refreshToken = nil
      
      UserDefaults.standard.set(false, forKey: "isUserAuthenticated")
      
      NotificationCenter.default.post(Notification(name: .logout,
                                                   object: nil,
                                                   userInfo: nil))
    }
  }
}
