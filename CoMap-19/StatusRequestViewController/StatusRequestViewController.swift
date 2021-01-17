//
//  StatusRequestViewController.swift
//  CoMap-19
//

//

import UIKit
import SVProgressHUD

enum RequestStatusType: String {
  case approve = "APPROVE"
  case alwaysApprove = "ALWAYS_APPROVE"
  case reject = "REJECT"
}

protocol StatusRequestViewControllerDelegate: AnyObject {
  func statusRequestViewController(_ vc: StatusRequestViewController,
                                   requestStatusChanged status: RequestStatusType)
}

final class StatusRequestViewController: UIViewController {

  // MARK: - Private variables
  
  fileprivate struct Defaults {
    static let cornerRadius: CGFloat = 25.0
    static let borderWidth: CGFloat = 1.0
    static let containerViewCornerRadius: CGFloat = 8.0
  }

  private var statusRequests: [StatusRequestResponse]?
  
  fileprivate var successfullRequest:[String: (Bool, RequestStatusType)] = [:]
    
  // MARK: - IBOutlets
  
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.showsHorizontalScrollIndicator = false
      collectionView.isPagingEnabled = false
    }
  }
  
  // MARK: - Public variables
  
  weak var delegate: StatusRequestViewControllerDelegate?
  
  // MARK: - Init methods
   
  convenience init(statusRequests: [StatusRequestResponse]) {
    self.init(nibName: "StatusRequestViewController", bundle: nil)
    
    self.statusRequests = statusRequests
    setupViewController()
  }
   
   required init?(coder aDecoder: NSCoder) {
     fatalError("init(coder:) has not been implemented")
   }
   
   override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
     super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
   }
  
  // MARK: - View Life cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    prepareCollectionView()
  }
  
  // MARK: - Public methods
  
  func refreshRequests(statusRequests: [StatusRequestResponse]) {
    self.statusRequests = statusRequests
    self.collectionView.reloadData()
  }
  
  // MARK: - Private methods
  
  fileprivate func prepareCollectionView() {
    registerTableViewCells()
    
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  fileprivate func registerTableViewCells() {
    collectionView.register(UINib(nibName: String(describing: StatusRequestCollectionViewCell.self), bundle: nil),
                            forCellWithReuseIdentifier: String(describing: StatusRequestCollectionViewCell.self))
  }
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
  }
  

  fileprivate func sendStatusRequestApproval(type: RequestStatusType, requestId: String) {
    
    SVProgressHUD.show()
    
    let params = [Constants.ApiKeys.requestStatus: type.rawValue,
                  Constants.ApiKeys.id : requestId]

    APIClient.sharedInstance.sendStatusRequestApproval(approval: params) { [weak self] (responseObject, _, error) in

      SVProgressHUD.dismiss()
      
      guard let self = self else {
        return
      }

      if let error = error {
        ToastView.showToastMessage(error)
      }
      else {
        StatusApprovalRequestManager.shared.pendingRequestCount -= 1
        self.delegate?.statusRequestViewController(self, requestStatusChanged: type)
        self.collectionView.reloadData()
        self.successfullRequest[requestId] = (true, type)
      }
    }
  }
  
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension StatusRequestViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInDismiss()
  }
  
}

// MARK: - UICollectionViewDataSource methods implementations

extension StatusRequestViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return statusRequests?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatusRequestCollectionViewCell", for: indexPath) as! StatusRequestCollectionViewCell
    
    if let statusRequest = statusRequests?[indexPath.row] {
      cell.delegate = self
      cell.configure(statusRequest: statusRequest, isSuccessfull: successfullRequest[statusRequest.requestId] ?? (false, .reject))
    }
    
    return cell
  }
}

// MARK: - UICollectionViewFlowLayout methods implementations

extension StatusRequestViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let collectionViewWidth =  collectionView.bounds.size.width - (statusRequests?.count == 1 ? 10 : 30)
    return CGSize(width: collectionViewWidth, height: collectionView.bounds.size.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
}

// MARK: - StatusRequestCollectionViewCellDelegate methods implementations

extension StatusRequestViewController: StatusRequestCollectionViewCellDelegate {
  
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       crossButtonTapped sender: UIButton) {
   
    if let indexPath = collectionView.indexPath(for: cell) {
      statusRequests?.remove(at: indexPath.row)
    }
    
    if statusRequests?.isEmpty == false {
      collectionView.reloadData()
    }
    else {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       approveButtonTapped sender: UIButton) {
    
    if let indexPath = collectionView.indexPath(for: cell), let requestId = statusRequests?[indexPath.row].requestId {
      
      if successfullRequest[requestId]?.0 == true {
        statusRequests?.remove(at: indexPath.row)
        
        if statusRequests?.isEmpty == true {
          self.dismiss(animated: true, completion: nil)
        }
        else {
          collectionView.reloadData()
        }
      }
      else {
        sendStatusRequestApproval(type: .approve, requestId: requestId)
      }
    }
  }
  
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       rejectButtonTapped sender: UIButton) {
    if let indexPath = collectionView.indexPath(for: cell), let requestId = statusRequests?[indexPath.row].requestId {
      sendStatusRequestApproval(type: .reject, requestId: requestId)
    }
  }
  
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       alwaysApproveButtonTapped sender: UIButton) {
    if let indexPath = collectionView.indexPath(for: cell), let requestId = statusRequests?[indexPath.row].requestId {
      sendStatusRequestApproval(type: .alwaysApprove, requestId: requestId)
    }
  }
  
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       reportAbuseButtonTapped sender: UIButton) {
    if let indexPath = collectionView.indexPath(for: cell), let requestId = statusRequests?[indexPath.row].requestId {
      let reportAbuseVC = ReportAbuseViewController(requestId: requestId)
      reportAbuseVC.delegate = self
      self.present(reportAbuseVC, animated: true, completion: nil)
    }
  }
}

// MARK: - ReportAbuseViewControllerDelegate methods implementations

extension StatusRequestViewController: ReportAbuseViewControllerDelegate {
 
  func requestReportedAbused(_ vc: ReportAbuseViewController, requestId: String) {
    StatusApprovalRequestManager.shared.pendingRequestCount -= 1
    statusRequests?.removeAll(where: {$0.requestId == requestId})
    self.delegate?.statusRequestViewController(self, requestStatusChanged: .reject)
    self.successfullRequest[requestId] = (true, .reject)
   
    if statusRequests?.isEmpty == true {
      self.dismiss(animated: true, completion: nil)
    }
    else {
      collectionView.reloadData()
    }
  }
}
