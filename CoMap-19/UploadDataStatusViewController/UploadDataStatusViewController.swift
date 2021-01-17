//
//  UploadDataStatusViewController.swift
//  CoMap-19
//

//
//

import UIKit

enum UploadDataStatusSourceType: String {
  case beingTested = "being_tested"
  case testedPositive = "tested_positive_consent"
  case selfConsent = "self_consent"
  case pushConsent = "push_consent"
}

final class UploadDataStatusViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      titleLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var subTitleLabel: UILabel! {
    didSet {
      subTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
      subTitleLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var actionButton: UIButton! {
    didSet {
      actionButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      actionButton.setTitleColor(UIColor.white, for: .normal)
      actionButton.layer.cornerRadius = 25.0
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8.0
    }
  }
  
  @IBOutlet weak var uploadImageContainerView: UIView!
  @IBOutlet weak var uploadStatusImageView: UIImageView!
  
  // MARK: - Private variables
  
  fileprivate enum UploadStatus {
    case userPermission
    case sending
    case error
    case success
  }
  
  fileprivate var uploadStatus: UploadStatus = .userPermission {
    didSet {
      updateUI()
    }
  }
    
  // MARK: - Public variables
  
  var sourceType: UploadDataStatusSourceType?
  var uploadKey: String?
  
  // MARK: - Init methods
  
  convenience init() {
    self.init(nibName: "UploadDataStatusViewController", bundle: nil)
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
    uploadStatus = .userPermission
  }
  
  fileprivate func updateUI() {
    switch uploadStatus {
    case .userPermission:
      titleLabel.text = Localization.toHelpContactTracing
      actionButton.setTitle(Localization.confirmAndProceed, for: .normal)
      subTitleLabel.isHidden = true
      uploadImageContainerView.isHidden = true
      actionButton.backgroundColor = UIColor(red: 240/255, green: 99/255, blue: 114/255, alpha: 1.0)
      
    case .sending:
      titleLabel.text = Localization.sendingInteractionData
      actionButton.setTitle(Localization.cancel, for: .normal)
      subTitleLabel.text = Localization.syncingData
      uploadStatusImageView.image = #imageLiteral(resourceName: "synching")
      subTitleLabel.textColor = UIColor.black
      subTitleLabel.isHidden = false
      uploadImageContainerView.isHidden = false
      actionButton.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
      
    case .error:
      titleLabel.text = Localization.somethingWentWrong
      subTitleLabel.text = Localization.syncFailed
      actionButton.setTitle(Localization.retry, for: .normal)
      uploadStatusImageView.image = #imageLiteral(resourceName: "sync_failure")
      subTitleLabel.isHidden = false
      subTitleLabel.textColor = UIColor(red: 207/255, green: 56/255, blue: 30/255, alpha: 1.0)
      uploadImageContainerView.isHidden = false
      actionButton.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
      
    case .success:
      titleLabel.text = Localization.yourDataSecured
      subTitleLabel.text = Localization.syncSuccessful
      actionButton.setTitle(Localization.ok, for: .normal)
      uploadStatusImageView.image = #imageLiteral(resourceName: "sync_successful")
      subTitleLabel.textColor = UIColor(red: 36/255, green: 153/255, blue: 149/255, alpha: 1.0)
      subTitleLabel.isHidden = false
      uploadImageContainerView.isHidden = false
      actionButton.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
      
    }
  }
  
  // MARK: - IBActions
  
  fileprivate func sendData() {
    if var json = DAOManagerImpl.shared.getUserData() {
      uploadStatus = .sending
      
      if sourceType == .pushConsent, let uploadKey = uploadKey {
        json["upload_type"] = uploadKey
      }
      else {
        json["upload_type"] = sourceType?.rawValue
      }
      
      APIClient.sharedInstance.uploadBluetoothScans(paramDict: json) { [weak self] (success, error) in
        if let success = success as? [String: Any], success[Constants.ApiKeys.error] != nil {
          self?.uploadStatus = .error
        }
        else if error != nil {
          self?.uploadStatus = .error
        }
        else {
          self?.uploadStatus = .success
        }
      }
    }
    else {
      uploadStatus = .success
    }
  }
  
  @IBAction func actionButtonTapped(_ sender: UIButton) {
    switch uploadStatus {
    case .userPermission:
      sendData()
      
    case .sending:
      self.dismiss(animated: true, completion: nil)
      
    case .error:
      sendData()
      
    case .success:
      self.dismiss(animated: true, completion: nil)
      
    }
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension UploadDataStatusViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInDismiss()
  }
  
}
