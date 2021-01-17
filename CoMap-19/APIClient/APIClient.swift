//
//  APIClient.swift
//  CoMap-19
//

//
//

import Foundation
import UIKit
import Gzip

final class APIClient {
  
  // MARK: - Public variables
  
  static let sharedInstance = APIClient()
  var authorizationToken: String?
  var refreshToken: String?
  var retryCount:Int = 0
  
  // MARK: - Private variables
  
  fileprivate var session: URLSession?
  
  // MARK: - Initialization methods
  
  private init() {
    session = URLSession(configuration: .ephemeral,
                         delegate: Constants.SSLPinning.enabled ? URLSessionPinningDelegate() : nil,
                         delegateQueue: OperationQueue.main)
  }
    
  static func deviceModelDescription() -> String{
    var utsnameInstance = utsname()
    uname(&utsnameInstance)
    
    var model:String?
    
    if model == nil {
      model = withUnsafePointer(to: &utsnameInstance.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
          ptr in String.init(validatingUTF8: ptr)
        }
      }
    }
    return model ?? "N/A"
  }
  
  //MARK:- Common Headers
 
  private func appendCommonHeaders( request: inout URLRequest, shouldSendLocation: Bool = false) {
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(Constants.platformToken, forHTTPHeaderField: "pt")
    request.setValue(Constants.NetworkParams.version, forHTTPHeaderField: Constants.NetworkParams.versionKey)
    request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: Constants.NetworkParams.osKey)
    request.setValue(UserDefaults.standard.string(forKey: Constants.UserDefault.selectedLanguageKey),
                     forHTTPHeaderField: Constants.NetworkParams.langKey)
    request.setValue(APIClient.deviceModelDescription(), forHTTPHeaderField: Constants.NetworkParams.deviceModelKey)
    
    if shouldSendLocation {
      let location = DAOManagerImpl.shared.currentLocation
      var latitude, longitude: String?
      if let lat = location?.lat {
        latitude = String(format: "%f", lat)
        request.setValue(latitude, forHTTPHeaderField: Constants.NetworkParams.lat)
      }
      if let long = location?.lon {
        longitude = String(format: "%f", long)
        request.setValue(longitude, forHTTPHeaderField: Constants.NetworkParams.lon)
      }
    }
  }
  
  //MARK:- API Methods
  
  func registerUser(name: String?,
                     macAddress: String?,
                     fcmToken: String?,
                     lat: String?,
                     lon: String?,
                     completion: @escaping(_ responseObject: Any?, _ error: Error?) -> Void) {
     
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.registerUser)
     
     guard let serviceUrl = URL(string: Url) else {
       return
     }
     var parameterDictionary = [String: Any]()
     
     if let name = name {
       parameterDictionary["n"] = name
     }
     
     if let fcmToken = fcmToken {
       parameterDictionary["ft"] = fcmToken
     }
     
     if let macAddress = macAddress {
       parameterDictionary["mac"] = macAddress
     }
     
     if let lat = lat {
       parameterDictionary["lat"] = lat
     }
     
     if let lon = lon {
       parameterDictionary["lon"] = lon
     }
     
     parameterDictionary["is_loc_on"] = Permission.isLocationOn()
     parameterDictionary["is_loc_allowed"] = Permission.isLocationPermissionAllowed()
     parameterDictionary["is_bl_on"] = Permission.isBluetoothOn()
     parameterDictionary["is_bl_allowed"] = Permission.isBluetoothPermissionAllowed()
     
     var request = URLRequest(url: serviceUrl)
     request.httpMethod = Constants.NetworkParams.httpMethodPost
     
     guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
       return
     }
     request.httpBody = httpBody
     
     if let authorizationToken = authorizationToken {
       request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
     }
     
     appendCommonHeaders(request: &request, shouldSendLocation: true)
     
     session?.dataTask(with: request) { (data, response, error) in
       if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, nil)
        } catch let parsingError {
          completion(nil, parsingError)
        }
       }
       else {
        completion(nil, error)
      }
     }.resume()
  }
  
  func uploadBluetoothScans(paramDict: [String: Any],
                            completion: @escaping(_ responseObject: Any?, _ error: Error?) -> Void)  {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.bulkUpload)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
     request.httpMethod = Constants.NetworkParams.httpMethodPost
     request.setValue("gzip", forHTTPHeaderField:Constants.NetworkParams.acceptEncoding)
     
     guard let httpBody = try? JSONSerialization.data(withJSONObject: paramDict, options: []) else {
       return
     }
     let optimizedData: Data = try! httpBody.gzipped(level: .bestCompression)
     request.httpBody = optimizedData
     
     if let authorizationToken = authorizationToken {
       request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
     }
     
     appendCommonHeaders(request: &request)
     
     session?.dataTask(with: request) { (data, response, error) in
       if let data = data {
         do {
           let json = try JSONSerialization.jsonObject(with: data, options: [])
           completion(json, nil)
         } catch let parsingError {
          completion(nil, parsingError)
        }
       }
       else {
        completion(nil, error)
      }
     }.resume()
  }
  
  func getUserStatus(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void)  {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.userStatus)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    
    request.httpBody = nil
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    appendCommonHeaders(request: &request)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func getAppConfig(completion: @escaping(_ data: Data?, _ error: Error?) -> Void) {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.appConfig)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    
    appendCommonHeaders(request: &request)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        completion(data, nil)
      }
      else {
        completion(nil, error)
      }
    }.resume()
  }

  func sendFCMToken(_ token: String?)  {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.registerFcmToken)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var parameterDictionary = [String: Any]()
    
    if let token = token {
      parameterDictionary["ft"] = token
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost

    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    appendCommonHeaders(request: &request)
    
    session?.dataTask(with: request) { (data, response, error) in
      
    }.resume()
  }
  
  func generateOTP(postDict:[String:String], completion: @escaping(_ responseObject: Any?, _ error: Error?) -> Void)  {
    let Url = String(format: "%@/%@", Constants.authBaseUrl, ApiEndPoints.generateOTP)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    request.setValue(Constants.apiKeyValue, forHTTPHeaderField: Constants.NetworkParams.apiKey)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, nil)
        } catch let parsingError {
          completion(nil, parsingError)
        }
      }
      else {
        completion(nil, error)
      }
    }.resume()
  }
  
  func validateOTP(postDict:[String:Any], completion: @escaping(_ responseObject: Any?, _ error: Error?) -> Void)  {
    let Url = String(format: "%@/%@", Constants.authBaseUrl, ApiEndPoints.validateOTP)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: postDict, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    request.setValue(Constants.apiKeyValue, forHTTPHeaderField: Constants.NetworkParams.apiKey)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, nil)
        } catch let parsingError {
          completion(nil, parsingError)
        }
      }
      else {
        completion(nil, error)
      }
    }.resume()
  }
  
  func refreshToken(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?, _ error: Error?) -> Void)  {
    let Url = String(format: "%@/%@", Constants.authBaseUrl, ApiEndPoints.refreshToken)
    
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    
    if let refreshToken = refreshToken {
      request.setValue(refreshToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    appendCommonHeaders(request: &request)
    request.setValue(Constants.apiKeyValue, forHTTPHeaderField: Constants.NetworkParams.apiKey)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func getQrCode(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void) {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.generateQrCode)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = nil
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    appendCommonHeaders(request: &request)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func getQrPublicKey(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void) {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.publicQrKey)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = nil
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func sendStatusRequestApproval(approval: [String: String], completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: String?) -> Void) {
   
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.statusRequestApproval)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: approval, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          
          if let json = json as? [String: Any],
             let error = json[Constants.ApiKeys.error] as? [String: String],
             let message = error[Constants.ApiKeys.message] {
            completion(nil, response, message)
          }
          else {
            completion(json, response, nil)
          }
        } catch let parsingError {
          completion(nil, response, parsingError.localizedDescription)
        }
      }
      else {
        completion(nil, response, error?.localizedDescription)
      }
    }.resume()
  }
  
  func getPendingRequestApproval(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.statusRequestApproval)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
  
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func deleteAccount(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void) {
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, "api/v1/account/delete/")
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    request.httpBody = nil
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    appendCommonHeaders(request: &request)
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func getUserStatusPreferences(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.userPreferences)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func sendUserPreference(preference: [String: Any], completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: String?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.userPreferences)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: preference, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          
          if let json = json as? [String: Any],
            let error = json[Constants.ApiKeys.error] as? [String: String],
            let message = error[Constants.ApiKeys.message] {
            completion(nil, response, message)
          }
          else {
            completion(json, response, nil)
          }
        }
        catch let parsingError {
          completion(nil, response, parsingError.localizedDescription)
        }
      }
      else {
        completion(nil, response, error?.localizedDescription)
      }
    }.resume()
  }
  
  func getMsmeStatus(completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: Error?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.msmeStatus)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodGet
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          completion(json, response, nil)
        } catch let parsingError {
          completion(nil, response, parsingError)
        }
      }
      else {
        completion(nil, response, error)
      }
    }.resume()
  }
  
  func verifyMsmeStatus(params: [String: String], completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: String?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.verifyMsmeStatus)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          
          if let json = json as? [String: Any],
            let error = json[Constants.ApiKeys.error] as? [String: String],
            let message = error[Constants.ApiKeys.message] {
            completion(nil, response, message)
          }
          else {
            completion(json, response, nil)
          }
        }
        catch let parsingError {
          completion(nil, response, parsingError.localizedDescription)
        }
      }
      else {
        completion(nil, response, error?.localizedDescription)
      }
    }.resume()
  }
  
  func initiateMsmeRequest(params: [String: String], completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: String?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.initiateMsmeRequest)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          
          if let json = json as? [String: Any],
            let error = json[Constants.ApiKeys.error] as? [String: String],
            let message = error[Constants.ApiKeys.message] {
            completion(nil, response, message)
          }
          else {
            completion(json, response, nil)
          }
        }
        catch let parsingError {
          completion(nil, response, parsingError.localizedDescription)
        }
      }
      else {
        completion(nil, response, error?.localizedDescription)
      }
    }.resume()
  }
  
  func removeGrantMsmeRequest(params: [String: Any], completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: String?) -> Void) {

    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.removeGrantRequest)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in

      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          if let json = json as? [String: Any],
            let error = json[Constants.ApiKeys.error] as? [String: String],
            let message = error[Constants.ApiKeys.message] {
            completion(nil, response, message)
          }
          else {
            completion(json, response, nil)
          }
        }
        catch let parsingError {
          completion(nil, response, parsingError.localizedDescription)
        }
      }
      else {
        completion(nil, response, error?.localizedDescription)
      }
    }.resume()
  }
  
  func removeUserPreference(params: [String: Any], completion: @escaping(_ responseObject: Any?, _ response:URLResponse?,_ error: String?) -> Void) {
    
    let Url = String(format: "%@/%@", Constants.NetworkParams.baseUrl, ApiEndPoints.removeUserPref)
    guard let serviceUrl = URL(string: Url) else {
      return
    }
    
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = Constants.NetworkParams.httpMethodPost
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
      return
    }
    request.httpBody = httpBody
    
    appendCommonHeaders(request: &request)
    
    if let authorizationToken = authorizationToken {
      request.setValue(authorizationToken, forHTTPHeaderField: Constants.NetworkParams.authorizationKey)
    }
    
    session?.dataTask(with: request) { (data, response, error) in
      
      if let data = data {
        do {
          let json = try JSONSerialization.jsonObject(with: data, options: [])
          if let json = json as? [String: Any],
            let error = json[Constants.ApiKeys.error] as? [String: String],
            let message = error[Constants.ApiKeys.message] {
            completion(nil, response, message)
          }
          else {
            completion(json, response, nil)
          }
        }
        catch let parsingError {
          completion(nil, response, parsingError.localizedDescription)
        }
      }
      else {
        completion(nil, response, error?.localizedDescription)
      }
    }.resume()
  }
}
