//
//  AddStatusCheckAccountViewController.swift
//  CoMap-19
//

//

import UIKit

protocol AddStatusCheckAccountViewControllerDelegate: AnyObject {
  func userAddeddSuccessfull(_ vc: AddStatusCheckAccountViewController)
}
final class AddStatusCheckAccountViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var crossButton: UIButton! {
    didSet {
      crossButton.accessibilityLabel = AccessibilityLabel.dismiss
    }
  }
  
  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      submitButton.setTitleColor(.white, for: .normal)
      submitButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      submitButton.layer.cornerRadius = submitButton.bounds.size.height/2
      submitButton.setTitle(Localization.verifyAndAdd, for: .normal)
      submitButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      submitButton.accessibilityLabel = AccessibilityLabel.verifyAndAdd
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      titleLabel.textColor = .black
      titleLabel.text = Localization.enterCode
      titleLabel.accessibilityLabel = AccessibilityLabel.enterCode
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      subtitleLabel.textColor = #colorLiteral(red: 0.2235294118, green: 0.2196078431, blue: 0.2509803922, alpha: 1)
      subtitleLabel.text = Localization.getUniqueCode
      subtitleLabel.accessibilityLabel = AccessibilityLabel.getUniqueCode
    }
  }
  
  @IBOutlet weak var containerView: RoundCorners!
  
  @IBOutlet weak var codeTextField: FloatingLabelTextField! {
    didSet {
      codeTextField.keyboardType = .numberPad
      codeTextField.placeholder = Localization.code
      codeTextField.accessibilityLabel = AccessibilityLabel.code
    }
  }
  
  @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Public variables
  
  weak var delegate: AddStatusCheckAccountViewControllerDelegate?
  
  // MARK: - Init methods
  
  convenience init() {
    self.init(nibName: "AddStatusCheckAccountViewController", bundle: nil)
    
    setupViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  // MARK: - View Life Cycle methods
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    addKeyboardObservers()
  }
    
  override func viewWillDisappear(_ animated: Bool) {
    removeKeyboardObservers()
    
    super.viewWillDisappear(animated)
  }
  
  // MARK: - IBActions
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func submitButtonTapped(_ sender: UIButton) {
    if let code = codeTextField.text {
      submitButton.showLoading()
      
      verifyCode(code)
    }
    else {
      codeTextField.setError("Please enter valid 6 digit code")
    }
  }
  
  // MARK: - Private methods
  
  fileprivate func verifyCode(_ code: String) {
    
    let param = [Constants.ApiKeys.token: code]
    
    APIClient.sharedInstance.verifyMsmeStatus(params: param) { [weak self] (responseObject, _ response, error) in
      
      guard let self = self else {
        return
      }
      
      self.submitButton.hideLoading()
      
      if let error = error {
        ToastView.showToastMessage(error.description)
      }
      else {
        self.delegate?.userAddeddSuccessfull(self)
      }
    }
  }
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension AddStatusCheckAccountViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }
  
}

// MARK: - UIKeyboard observer methods

extension AddStatusCheckAccountViewController {

  fileprivate func addKeyboardObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
  }
  
  fileprivate func removeKeyboardObservers() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  @objc fileprivate func keyboardWillShow(_ sender: NSNotification) {
    
    if let keyboardSize = (sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size,
      let animationDuration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      
      var keyboardHeight = keyboardSize.height
      if #available(iOS 11.0, *) {
        if let rootWindow = UIApplication.shared.keyWindow,
          rootWindow.responds(to: #selector(getter: UIView.safeAreaInsets)) {
          keyboardHeight -= rootWindow.safeAreaInsets.bottom
        }
      }
      
      containerViewBottomConstraint.constant = keyboardHeight
      
      view.layoutIfNeeded()
      UIView.animate(withDuration: animationDuration, animations: {
        self.view.layoutIfNeeded()
      })
    }
  }
  
  @objc fileprivate func keyboardWillHide(_ sender: NSNotification) {
    
    if let animationDuration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      
      UIView.animate(withDuration: animationDuration, animations: {
        self.containerViewBottomConstraint.constant = 0
      })
    }
  }
}
