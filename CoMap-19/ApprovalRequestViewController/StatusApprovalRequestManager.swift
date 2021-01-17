//
//  StatusApprovalRequestManager.swift
//  CoMap-19
//

//

import UIKit

final class StatusApprovalRequestManager {
  
  // MARK: - Public properties
  
  var pendingRequests = [StatusRequestResponse]() {
    didSet {
      let uniqueRequest = pendingRequests.unique()
      pendingRequestCount = uniqueRequest.count
    
      if uniqueRequest.isEmpty == false {
        if let topVC = getTopViewController() {
          if let statusRequestVC = topVC as? StatusRequestViewController {
            statusRequestVC.refreshRequests(statusRequests: uniqueRequest)
          }
          else {
            let statusRequestVC = StatusRequestViewController(statusRequests: uniqueRequest)
            topVC.present(statusRequestVC, animated: true, completion: nil)
          }
        }
      }
    }
  }
  
  var pendingRequestCount = Int() {
    didSet {
      NotificationCenter.default.post(name: .requestStatusChanged, object: nil)
    }
  }
  
  // MARK: - Static properties
  
  static var shared = StatusApprovalRequestManager()
  
  // MARK: - Init methods
  
  private init() {}
  
  // MARK: - Public methods
  
  fileprivate func getTopViewController() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
      while let presentedViewController = topController.presentedViewController {
        topController = presentedViewController
      }
      
      return topController
      
    }
    
    return nil
  }
  
  func fetchPendingRequests() {
    
    DispatchQueue.global(qos: .userInitiated).async {
      
      APIClient.sharedInstance.getPendingRequestApproval { [weak self] (responseObject, _ response, error) in
        
        guard let self = self else {
          return
        }
        
        if let responseObject = responseObject as? [String: Any] {
          if let request = responseObject[Constants.ApiKeys.data] as? [Any] {
            do {
              let data = try JSONSerialization.data(withJSONObject: request, options: [])
              let decoder = JSONDecoder()
              decoder.keyDecodingStrategy = .convertFromSnakeCase
              let pendingRequests = try decoder.decode([PendingRequest].self, from: data).filter({$0.requestStatus == .pending})
              
              DispatchQueue.main.async {
                self.pendingRequests = pendingRequests.map { StatusRequestResponse(imageUrl: $0.imageUrl,
                                                                                   appName: $0.name,
                                                                                   requestId: $0.id,
                                                                                   reason: $0.reason,
                                                                                   startDate: $0.startDate,
                                                                                   endDate: $0.endDate) }
              }
            }
            catch _ {
            }
          }
        }
      }
    }
  }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
