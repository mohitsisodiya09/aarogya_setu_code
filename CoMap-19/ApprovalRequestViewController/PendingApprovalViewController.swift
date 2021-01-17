//
//  PendingApprovalViewController.swift
//  CoMap-19
//
//

import UIKit
import SVProgressHUD

final class PendingApprovalViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var emptyStateView: UIView!
  
  @IBOutlet weak var emptyStateTitleLabel: UILabel! {
    didSet {
      emptyStateTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
      emptyStateTitleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      emptyStateTitleLabel.text = Localization.pendingRequestTitle
    }
  }
  @IBOutlet weak var emptyStateSubtitleLabel: UILabel! {
    didSet {
      emptyStateSubtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 14.0)
      emptyStateSubtitleLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
      emptyStateSubtitleLabel.text = Localization.pendingRequestSubtitle
    }
  }
  
  // MARK: - Private variables
  
  fileprivate var pendingRequests: [PendingRequest]?
  
  // MARK: - View Life cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = Localization.approvals
    prepareTableView()
    fetchPendingRequests()
    addRefreshPendingRequestNavBarItem()
    self.hideEmptyStateView()
    self.tableView.isHidden = true
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: .languageChanged,
                                              object: nil)
  }
  
  // MARK: - Private methods
  
  fileprivate func addNotificationObserver() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(languageChanged),
                                           name: .languageChanged,
                                           object: nil)
  }
  
  @objc fileprivate func languageChanged(notification: NSNotification) {
    tableView.reloadData()
  }
  
  fileprivate func addRefreshPendingRequestNavBarItem() {
    self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(fetchPendingRequests))
  }
  
  @objc fileprivate func fetchPendingRequests() {
    
    SVProgressHUD.show()
    
    APIClient.sharedInstance.getPendingRequestApproval { [weak self] (responseObject, _ response, error) in
      
      SVProgressHUD.dismiss()
      
      guard let self = self else {
        return
      }
      
      if let responseObject = responseObject as? [String: Any] {
        if let request = responseObject[Constants.ApiKeys.data] as? [Any] {
          
          do {
            let data = try JSONSerialization.data(withJSONObject: request, options: [])
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let pendingRequests = try decoder.decode([PendingRequest].self, from: data)
            self.pendingRequests = pendingRequests
            
            if pendingRequests.isEmpty == true {
              self.showEmptyStateView()
              self.tableView.isHidden = true
            }
            else {
              self.hideEmptyStateView()
              self.tableView.isHidden = false
              self.tableView.reloadData()
            }
          }
          catch let error {
            ToastView.showToastMessage(error.localizedDescription)
          }
        }
        else if let error = responseObject[Constants.ApiKeys.error] as? [String: Any],
          let message = error[Constants.ApiKeys.message] as? String {
          ToastView.showToastMessage(message)
        }
      }
    }
  }
  
  fileprivate func prepareTableView() {
    tableView.register(UINib(nibName: String(describing: PendingRequestTableViewCell.self),
                             bundle: nil), forCellReuseIdentifier: String(describing: PendingRequestTableViewCell.self))
    
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none
    
    tableView.dataSource = self
  }
  
  fileprivate func showEmptyStateView() {
    emptyStateView.isHidden = false
  }
  
  fileprivate func hideEmptyStateView() {
    emptyStateView.isHidden = true
  }
}

// MARK: - UITableViewDataSource methods implementations

extension PendingApprovalViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRequestTableViewCell")! as! PendingRequestTableViewCell
    
    if let request = pendingRequests?[indexPath.row] {
      cell.delegate = self
      cell.configure(request: request)
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return pendingRequests?.count ?? 0
  }
}

// MARK: - PendingRequestTableViewCellDelegate methods implementations

extension PendingApprovalViewController: PendingRequestTableViewCellDelegate {

  func pendingRequestTableViewCell(_ cell: PendingRequestTableViewCell, viewAllRequestButtonTapped sender: UIButton) {
    
    if let indexPath = tableView.indexPath(for: cell), let request = pendingRequests?[indexPath.row] {
      let statusRequest = StatusRequestResponse(imageUrl: request.imageUrl,
                                                appName: request.name,
                                                requestId: request.id,
                                                reason: request.reason,
                                                startDate: request.startDate,
                                                endDate: request.endDate)
     
      let statusRequestVC = StatusRequestViewController(statusRequests: [statusRequest])
      statusRequestVC.delegate = self
      self.present(statusRequestVC, animated: true, completion: nil)
    }
  }
}

// MARK: - StatusRequestViewControllerDelegate methods implementations

extension PendingApprovalViewController: StatusRequestViewControllerDelegate {
  
  func statusRequestViewController(_ vc: StatusRequestViewController,
                                   requestStatusChanged status: RequestStatusType) {
    fetchPendingRequests()
  }
}
