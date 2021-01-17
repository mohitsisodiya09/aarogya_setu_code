//
//  ShareStatusCodeViewController.swift
//  CoMap-19
//

//

import UIKit

final class ShareStatusCodeViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var crossButton: UIButton! {
    didSet {
      crossButton.accessibilityLabel = String(format: "%@ %@", AccessibilityLabel.dismiss, AccessibilityLabel.login)
    }
  }
  
  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      submitButton.setTitleColor(.white, for: .normal)
      submitButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      submitButton.layer.cornerRadius = submitButton.bounds.size.height/2
      submitButton.setTitle(Localization.generateCode, for: .normal)
      submitButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      submitButton.accessibilityLabel = AccessibilityLabel.generateCode
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      titleLabel.textColor = .black
      titleLabel.text = Localization.enterMobileNumber
      titleLabel.accessibilityLabel = AccessibilityLabel.enterMobileNumber
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      subtitleLabel.textColor = #colorLiteral(red: 0.2235294118, green: 0.2196078431, blue: 0.2509803922, alpha: 1)
      subtitleLabel.text = Localization.enterMobileNumberStatus
      subtitleLabel.accessibilityLabel = AccessibilityLabel.enterMobileNumberStatus
    }
  }
  
  @IBOutlet weak var containerView: RoundCorners! 
  
  @IBOutlet weak var mobileNumberTextField: FloatingLabelTextField! {
    didSet {
      mobileNumberTextField.delegate = self
      mobileNumberTextField.keyboardType = .numberPad
      mobileNumberTextField.placeholder = Localization.mobileNumber
      mobileNumberTextField.accessibilityLabel = AccessibilityLabel.mobileNumber
    }
  }
  
  @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Init methods
  
  convenience init() {
    self.init(nibName: "ShareStatusCodeViewController", bundle: nil)
    setupViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  // MARK: - View life cycle methods
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    addKeyboardObservers()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    mobileNumberTextField.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeKeyboardObservers()
    
    super.viewWillDisappear(animated)
  }
  
  // MARK: - Private methods
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
  }
  
  fileprivate func isMobileNumberValid() -> Bool {
    return (mobileNumberTextField.text?.isNumber() == true && mobileNumberTextField.text?.count == 10)
  }
  
  // MARK: - IBActions
  
  @IBAction func submitButtonTapped(_ sender: UIButton) {
    view.endEditing(true)
   
    if let mobileNumber = mobileNumberTextField.text,
      isMobileNumberValid() {
      submitButton.showLoading()
     
      let params = [Constants.ApiKeys.mobileNumber: mobileNumber]
      
      APIClient.sharedInstance.initiateMsmeRequest(params: params) { [weak self] (responseObject, _ response, error) in
       
        guard let self = self else {
          return
        }
        
        self.submitButton.hideLoading()
        
        if let error = error {
          ToastView.showToastMessage(error)
        }
        else if let responseObject = responseObject as? [String: Any] {
          if let data = responseObject[Constants.ApiKeys.data] as? [String: Any],
             let token = data[Constants.ApiKeys.token] as? Int {
            let shareCodeVC = StatusCodeViewController(code: "\(token)", mobileNumber: mobileNumber)
            let presentingVC = self.presentingViewController
           
            presentingVC?.dismiss(animated: true) {
              presentingVC?.present(shareCodeVC, animated: true, completion: nil)
            }
          }
        }
      }
    }
    else {
      mobileNumberTextField.setError(Localization.invalidMobileNo)
    }
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension ShareStatusCodeViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }

}

extension ShareStatusCodeViewController: UITextFieldDelegate {

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == mobileNumberTextField {
      let newLength = (textField.text ?? "").utf16.count + string.utf16.count - range.length
      return newLength <= 10
    }
    return true
  }
  
}

extension ShareStatusCodeViewController {
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
