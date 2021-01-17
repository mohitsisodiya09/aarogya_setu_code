//
//  WhyLoginNeededViewController.swift
//  CoMap-19
//
//
//

import UIKit

final class WhyLoginNeededViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var crossButton: UIButton! {
    didSet {
      crossButton.accessibilityLabel = AccessibilityLabel.dismiss
    }
  }

  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      submitButton.setTitleColor(.white, for: .normal)
      submitButton.titleLabel?.font = UIFont(name: "AvenirNext-Demibold", size: 16.0)
      submitButton.layer.cornerRadius = submitButton.bounds.size.height/2
      submitButton.setTitle(Localization.iUnderstand, for: .normal)
      submitButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      submitButton.accessibilityLabel = AccessibilityLabel.iUnderstand
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      titleLabel.textColor = .black
      titleLabel.text = Localization.yourMobileNumberIsRequiredToKnowYourIdentity
      titleLabel.accessibilityLabel = AccessibilityLabel.yourMobileNumberIsRequiredToKnowYourIdentity
    }
  }
  
  @IBOutlet weak var subTitleLabel: UILabel! {
    didSet {
      subTitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
      subTitleLabel.textColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      subTitleLabel.text = Localization.whyIsItNeededSubTitle
      subTitleLabel.accessibilityLabel = AccessibilityLabel.whyIsItNeededSubTitle
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = 16.0
    }
  }
  
  // MARK: - Initialization methods
  
  convenience init() {
    self.init(nibName: "WhyLoginNeededViewController", bundle: nil)
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
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
  }
  
  // MARK: - IBActions
  
  @IBAction func submitButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension WhyLoginNeededViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }

}
