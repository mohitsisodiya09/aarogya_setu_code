//
//  UploadDataConsentViewController.swift
//  CoMap-19
//

//
//

import UIKit

protocol UploadDataConsentViewControllerDelegate: AnyObject {
 
  func uploadDataConsentViewController(_ vc: UploadDataConsentViewController,
                                       beingTestedButtonTapped button: UIButton)
  func uploadDataConsentViewController(_ vc: UploadDataConsentViewController,
                                       testedPositiveButtonTapped button: UIButton)
  func uploadDataConsentViewController(_ vc: UploadDataConsentViewController,
                                       closeButtonTapped button: UIButton)
}

enum UploadDataConsentType {
  case testedPositive
  case beingTested
  case noneOfAbove
  case none
}

final class UploadDataConsentViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = Localization.uploadDataConsentTitle
      titleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      titleLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.text = Localization.uploadDataConsentSubTitle
      subtitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
      subtitleLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var testedPositiveLabel: UILabel! {
    didSet {
      testedPositiveLabel.text = Localization.testedPositive
      testedPositiveLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      testedPositiveLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var beingTestedLabel: UILabel! {
    didSet {
      beingTestedLabel.text = Localization.beingTested
      beingTestedLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      beingTestedLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var noneOfAboveLabel: UILabel! {
    didSet {
      noneOfAboveLabel.text = Localization.noneOfAbove
      noneOfAboveLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      noneOfAboveLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var testedPositiveIconImageView: UIImageView!
  @IBOutlet weak var beingTestedIconImageView: UIImageView!
  @IBOutlet weak var noneOfAboveIconImageView: UIImageView!
  
  @IBOutlet weak var testedPositiveButton: UIButton!
  @IBOutlet weak var beingTestedIconButton: UIButton!
  @IBOutlet weak var noneOfAboveIconButton: UIButton!
  
  @IBOutlet weak var actionButton: UIButton! {
    didSet {
      actionButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      actionButton.setTitleColor(UIColor.white, for: .normal)
      actionButton.layer.cornerRadius = 25.0
      actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8.0
    }
  }
  
  // MARK: - Private variables
  
  fileprivate var consentType: UploadDataConsentType = .none {
    didSet {
      setupUI()
    }
  }
  
  // MARK: - Public variables
  
  weak var delegate: UploadDataConsentViewControllerDelegate?
  
  // MARK: - Init methods
  
  convenience init() {
    self.init(nibName: "UploadDataConsentViewController", bundle: nil)
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
  
  @IBAction func beingTestedTapped(_ sender: UIButton) {
    consentType = .beingTested
  }
  
  @IBAction func testedPositiveTapped(_ sender: UIButton) {
    consentType = .testedPositive
  }
  
  @IBAction func noneOfAboveTapped(_ sender: UIButton) {
    consentType = .noneOfAbove
  }
  
  @IBAction func actionButtonTapped(_ sender: UIButton) {
    
    switch consentType {
    case .beingTested:
      delegate?.uploadDataConsentViewController(self, beingTestedButtonTapped: sender)
      
    case .testedPositive:
      delegate?.uploadDataConsentViewController(self, testedPositiveButtonTapped: sender)
      
    case .noneOfAbove:
      delegate?.uploadDataConsentViewController(self, closeButtonTapped: sender)
      
    default:
      break
    }
  }
    
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Private methods
  
  fileprivate func setupUI() {
    beingTestedIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    testedPositiveIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    noneOfAboveIconImageView.image = #imageLiteral(resourceName: "inactive_radio_icon")
    
    switch consentType {
  
    case .beingTested:
      actionButton.isHidden = false
      actionButton.setTitle(Localization.next, for: .normal)
      actionButton.backgroundColor = UIColor(red: 240/255, green: 99/255, blue: 114/255, alpha: 1.0)
      beingTestedIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
      
    case .testedPositive:
      actionButton.isHidden = false
      actionButton.setTitle(Localization.next, for: .normal)
      actionButton.backgroundColor = UIColor(red: 240/255, green: 99/255, blue: 114/255, alpha: 1.0)
      testedPositiveIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
      
    case .noneOfAbove:
      actionButton.isHidden = false
      actionButton.setTitle(Localization.close, for: .normal)
      actionButton.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
      noneOfAboveIconImageView.image = #imageLiteral(resourceName: "active_radio_icon")
    
    case .none:
      actionButton.isHidden = true
    }
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension UploadDataConsentViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInDismiss()
  }
  
}
