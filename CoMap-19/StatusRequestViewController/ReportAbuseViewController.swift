//
//  ReportAbuseViewController.swift
//  CoMap-19
//

//

import UIKit

enum ReportAbuseType: String {
  case notInitiated = "RA_NOT_INITIATED"
  case spam = "RA_SPAM"
  case others = "RA_OTHERS"
  case block = "RA_BLOCK"
  case none
}

protocol ReportAbuseViewControllerDelegate: AnyObject {
  func requestReportedAbused(_ vc: ReportAbuseViewController, requestId: String)
}

final class ReportAbuseViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = Localization.reportAbuseTitle
      titleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
      titleLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.text = Localization.reportAbuseSubtitle
      subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      subtitleLabel.textColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
    }
  }
  
  @IBOutlet weak var notInitiatedLabel: UILabel! {
    didSet {
      notInitiatedLabel.text = Localization.notInitiate
      notInitiatedLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      notInitiatedLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var spamLabel: UILabel! {
    didSet {
      spamLabel.text = Localization.spam
      spamLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      spamLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var othersLabel: UILabel! {
    didSet {
      othersLabel.text = Localization.other
      othersLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      othersLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var blockLabel: UILabel! {
    didSet {
      blockLabel.text = Localization.block
      blockLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      blockLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var notInitiatedIconImageView: UIImageView!
  @IBOutlet weak var spamIconImageView: UIImageView!
  @IBOutlet weak var othersIconImageView: UIImageView!
  @IBOutlet weak var blockIconImageView: UIImageView!
  
  @IBOutlet weak var notInitiatedButton: UIButton!
  @IBOutlet weak var spamIconButton: UIButton!
  @IBOutlet weak var othersIconButton: UIButton!
  @IBOutlet weak var blockIconButton: UIButton!
  
  @IBOutlet weak var actionButton: UIButton! {
    didSet {
      actionButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      actionButton.setTitleColor(UIColor.white, for: .normal)
      actionButton.layer.cornerRadius = 25.0
      actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
      actionButton.setTitle(Localization.report, for: .normal)
      actionButton.backgroundColor = UIColor(red: 240/255, green: 99/255, blue: 114/255, alpha: 1.0)
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8.0
    }
  }
  
  // MARK: - Private variables
   
   fileprivate var abuseType: ReportAbuseType = .none {
     didSet {
       setupUI()
     }
   }
  
  fileprivate var requestId: String?
    
  // MARK: - Public variables
  
  weak var delegate: ReportAbuseViewControllerDelegate?
  
  // MARK: - Init methods
  
  convenience init(requestId: String) {
    self.init(nibName: "ReportAbuseViewController", bundle: nil)
    self.requestId = requestId
    setupViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    setupUI()
  }
  
  // MARK: - IBActions
  
  @IBAction func othersTapped(_ sender: UIButton) {
    abuseType = .others
  }
  
  @IBAction func notInitiatedTapped(_ sender: UIButton) {
    abuseType = .notInitiated
  }
  
  @IBAction func spamTapped(_ sender: UIButton) {
    abuseType = .spam
  }
  
  @IBAction func blockTapped(_ sender: UIButton) {
     abuseType = .block
   }
  
  @IBAction func actionButtonTapped(_ sender: UIButton) {
    sendStatusRequestApproval()
  }
    
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Private methods
  
  fileprivate func sendStatusRequestApproval() {
    
    guard let requestId = requestId else {
      return
    }
    
    actionButton.showLoading()
    
    let params = [Constants.ApiKeys.requestStatus: abuseType.rawValue,
                  Constants.ApiKeys.id : requestId]
    
    APIClient.sharedInstance.sendStatusRequestApproval(approval: params) { [weak self] (responseObject, _, error) in
            
      guard let self = self else {
        return
      }
      
      self.actionButton.hideLoading()

      if let error = error {
        ToastView.showToastMessage(error)
      }
      else {
        self.dismiss(animated: true) {
          self.delegate?.requestReportedAbused(self, requestId: requestId)
        }
      }
    }
  }
  
  fileprivate func setupUI() {
    notInitiatedIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    othersIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    spamIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    blockIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    
    switch abuseType {
  
    case .notInitiated:
      actionButton.isHidden = false
      notInitiatedIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
      
    case .others:
      actionButton.isHidden = false
      othersIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
      
    case .spam:
      actionButton.isHidden = false
      spamIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
      
    case .block:
      actionButton.isHidden = false
      blockIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
    
    case .none:
      actionButton.isHidden = true
    }
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension ReportAbuseViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInDismiss()
  }
  
}
