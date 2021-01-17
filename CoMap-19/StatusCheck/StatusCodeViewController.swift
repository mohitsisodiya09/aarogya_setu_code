//
//  StatusCodeViewController.swift
//  CoMap-19
//

//

import UIKit

final class StatusCodeViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var crossButton: UIButton! {
    didSet {
      crossButton.accessibilityLabel = String(format: "%@ %@", AccessibilityLabel.dismiss, AccessibilityLabel.login)
    }
  }
  
  @IBOutlet weak var shareButton: UIButton! {
    didSet {
      shareButton.setTitleColor(.white, for: .normal)
      shareButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      shareButton.layer.cornerRadius = 25.0
      shareButton.setTitle(Localization.share, for: .normal)
      shareButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      shareButton.accessibilityLabel = AccessibilityLabel.share
    }
  }
  
  @IBOutlet weak var copyButton: UIButton! {
    didSet {
      copyButton.setTitleColor(.white, for: .normal)
      copyButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      copyButton.layer.cornerRadius = 25.0
      copyButton.setTitle(Localization.copy, for: .normal)
      copyButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      copyButton.accessibilityLabel = AccessibilityLabel.copy
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
      titleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      titleLabel.text = Localization.shareYourCode
      titleLabel.accessibilityLabel = AccessibilityLabel.shareYourCode
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
      subtitleLabel.textColor = #colorLiteral(red: 0.2235294118, green: 0.2196078431, blue: 0.2509803922, alpha: 1)
    }
  }
  
  @IBOutlet weak var codeLabel: UILabel! {
    didSet {
      codeLabel.font = UIFont(name: "AvenirNext-Medium", size: 18.0)
      codeLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
    }
  }
  
  @IBOutlet weak var codeValidDurationLabel: UILabel! {
    didSet {
      codeValidDurationLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
      codeValidDurationLabel.textColor = #colorLiteral(red: 0.003921568627, green: 0.5803921569, blue: 0.262745098, alpha: 1)
      codeValidDurationLabel.text = Localization.codeValidDuration
    }
  }
  
  @IBOutlet weak var codeContainerView: DashedBorderView! {
    didSet {
      codeContainerView.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9607843137, blue: 1, alpha: 1)
      codeContainerView.layer.cornerRadius = 8.0
      codeContainerView.side = .all(insets: UIEdgeInsets.zero)
      codeContainerView.dotColor = #colorLiteral(red: 0, green: 0.5490196078, blue: 1, alpha: 1)
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 8.0
    }
  }
  
  // MARK: - Private variables
  
  fileprivate var code: String?
  fileprivate var mobileNumber: String?
  
  // MARK: - Init methods
  
  convenience init(code: String, mobileNumber: String) {
    self.init(nibName: "StatusCodeViewController", bundle: nil)
    self.code = code
    self.mobileNumber = mobileNumber
    setupViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  // MARK: - Private methods
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    setupUI()
  }
  
  fileprivate func setupUI() {
    codeLabel.text = code
    subtitleLabel.text = String(format: Localization.shareYourCodeMobile, mobileNumber ?? "")
  }
  
  // MARK: - IBActions
  
  @IBAction func shareButtonTapped(_ sender: UIButton) {
    let permission = Permission(viewController: self)
    permission.shareMessage(String(format: "%@ \nCode: %@", Localization.shareYourCode, code ?? ""))
  }
  
  @IBAction func copyButtonTapped(_ sender: UIButton) {
    UIPasteboard.general.string = code
    ToastView.showToastMessage("Code copied")
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension StatusCodeViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInDismiss()
  }
  
}
