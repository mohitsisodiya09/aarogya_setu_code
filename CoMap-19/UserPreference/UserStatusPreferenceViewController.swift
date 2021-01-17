//
//  UserStatusPreferenceViewController.swift
//  CoMap-19
//
//

import UIKit
import SVProgressHUD

fileprivate enum UserPreferenceType: String {
  case alwaysApprove = "ALWAYS_APPROVE"
  case askForApproval = "ALWAYS_ASK"
  case block = "BLOCK"
}

protocol UserStatusPreferenceViewControllerDelegate: AnyObject {
  func userStatusPreferenceChanged(vc: UserStatusPreferenceViewController)
}

final class UserStatusPreferenceViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var appNameLabel: UILabel! {
    didSet {
      appNameLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
      appNameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    }
  }
  
  @IBOutlet weak var appIconImageView: UIImageView! {
    didSet {
      appIconImageView.layer.cornerRadius = 4.0
    }
  }
  
  @IBOutlet weak var alwaysApproveButton: UIButton! {
    didSet {
      alwaysApproveButton.setTitleColor(#colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1), for: .normal)
      alwaysApproveButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      alwaysApproveButton.setTitle(Localization.alwaysApprove.capitalized, for: .normal)
    }
  }
  
  @IBOutlet weak var askForApprovalButton: UIButton! {
    didSet {
      askForApprovalButton.setTitleColor(#colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1), for: .normal)
      askForApprovalButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      askForApprovalButton.setTitle(Localization.askForApproval, for: .normal)
    }
  }
  
  @IBOutlet weak var blockButton: UIButton! {
    didSet {
      blockButton.setTitleColor(#colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1), for: .normal)
      blockButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      blockButton.setTitle(Localization.block, for: .normal)
    }
  }
  
  @IBOutlet weak var removeButton: UIButton! {
    didSet {
      removeButton.setTitleColor(#colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1), for: .normal)
      removeButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      removeButton.setTitle(Localization.remove, for: .normal)
    }
  }
  
  @IBOutlet weak var containerView: RoundCorners!
  
  // MARK: - Public variables
  
  weak var delegate: UserStatusPreferenceViewControllerDelegate?
  
  // MARK: - Private variables
  
  fileprivate var statusPreference: UserStatusPreference?
  
  // MARK: - Init methods
  
  convenience init(statusPreference: UserStatusPreference) {
    self.init(nibName: "UserStatusPreferenceViewController", bundle: nil)
    self.statusPreference = statusPreference
    setupViewController()
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  // MARK: - Public methods
  
  fileprivate func setupUI() {
    
    if let name = statusPreference?.name {
      appNameLabel.text = name
      appNameLabel.isHidden = false
    }
    else {
      appNameLabel.isHidden = true
    }
    
    setAppImage(urlString: statusPreference?.imageUrl)
    
    blockButton.isHidden = statusPreference?.isUser == true
    alwaysApproveButton.isHidden = statusPreference?.isUser == true
    askForApprovalButton.isHidden = statusPreference?.isUser == true
  }
  
  // MARK: - Private methods
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    setupUI()
  }
  
  fileprivate func setAppImage(urlString: String?) {
    if let urlString = urlString, let url = URL(string: urlString) {
      do {
        let imageData = try Data(contentsOf: url)
        appIconImageView.image = UIImage(data: imageData)
        appIconImageView.isHidden = false
      }
      catch _ {
        appIconImageView.isHidden = true
      }
    }
    else if let name = statusPreference?.name, let firstLetter = name.first {
      appIconImageView.image = String(firstLetter).image()
      appIconImageView.isHidden = false
    }
    else {
      appIconImageView.isHidden = true
    }
  }
  
  fileprivate func sendUserPreference(type: UserPreferenceType) {
    
    guard let serviceProviderId = statusPreference?.serviceProviderId else {
      return
    }
    
    let prefernce: [String: Any] = [Constants.ApiKeys.serviceProviderId: serviceProviderId,
                                    Constants.ApiKeys.preference : type.rawValue]
    
    SVProgressHUD.show()
    
    APIClient.sharedInstance.sendUserPreference(preference: prefernce) { [weak self] (responseObject, _, error) in
      SVProgressHUD.dismiss()
      
      guard let self = self else {
        return
      }
      
      if let error = error {
        ToastView.showToastMessage(error)
      }
      else {
        self.delegate?.userStatusPreferenceChanged(vc: self)
      }
    }
  }
  
  // MARK: - IBAction
  
  @IBAction func alwaysApproveButtonTapped(_ sender: UIButton) {
    sendUserPreference(type: .alwaysApprove)
  }
  
  @IBAction func askForApprovalButtonTapped(_ sender: UIButton) {
    sendUserPreference(type: .askForApproval)
  }
  
  @IBAction func blockButtonTapped(_ sender: UIButton) {
    sendUserPreference(type: .block)
  }
  
  @IBAction func removeButtonTapped(_ sender: UIButton) {
    
    guard let serviceProviderId = statusPreference?.serviceProviderId else {
      return
    }
    
    let params: [String: Any] = [Constants.ApiKeys.serviceProviderId: serviceProviderId,
                                 Constants.ApiKeys.isUser : statusPreference?.isUser == true]
    
    SVProgressHUD.show()
    
    APIClient.sharedInstance.removeUserPreference(params: params) { [weak self] (responseObject, _, error) in
      SVProgressHUD.dismiss()
      
      guard let self = self else {
        return
      }
      
      if let error = error {
        ToastView.showToastMessage(error)
      }
      else {
        self.delegate?.userStatusPreferenceChanged(vc: self)
      }
    }
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension UserStatusPreferenceViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }
  
}
