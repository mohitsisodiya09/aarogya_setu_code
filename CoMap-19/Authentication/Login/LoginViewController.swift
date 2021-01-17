//
//  LoginViewController.swift
//  CoMap-19
//
//
//

import UIKit

class LoginViewController: UIViewController {

  var password:String = "Abc@123!"
  
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
      submitButton.setTitle(Localization.submit, for: .normal)
      submitButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      submitButton.accessibilityLabel = AccessibilityLabel.submit
    }
  }
  
  @IBOutlet weak var whyNeededButton: UIButton! {
    didSet {
      whyNeededButton.setTitle(Localization.whyIsItNeeded, for: .normal)
      whyNeededButton.accessibilityLabel = AccessibilityLabel.whyIsItNeeded
      whyNeededButton.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14.0)
      whyNeededButton.setTitleColor(UIColor(red: 34/255, green: 118/255, blue: 227/255, alpha: 1.0), for: .normal)
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
  
  @IBOutlet weak var containerView: RoundCorners!
  
  @IBOutlet weak var countryCodeTextField: UITextField! {
    didSet {
      countryCodeTextField.text = "+91"
      countryCodeTextField.delegate = self
      countryCodeTextField.keyboardType = .numbersAndPunctuation
      countryCodeTextField.placeholder = Localization.countryCode
      countryCodeTextField.tintColor = UIColor.black
      countryCodeTextField.accessibilityLabel = AccessibilityLabel.countryCode
    }
  }
  
  @IBOutlet weak var mobileNumberTextField: FloatingLabelTextField! {
    didSet {
      mobileNumberTextField.delegate = self
      mobileNumberTextField.keyboardType = .numberPad
      mobileNumberTextField.placeholder = Localization.mobileNumber
      mobileNumberTextField.accessibilityLabel = AccessibilityLabel.mobileNumber
    }
  }
  
  @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
  
  fileprivate let mobileNumberFieldTextLimit: Int = 10
  
  var shouldHideCloseButton = false
  
  convenience init() {
    self.init(nibName: "LoginViewController", bundle: nil)
    setupViewController()
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    addKeyboardObservers()
    
    crossButton.isHidden = shouldHideCloseButton
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    mobileNumberTextField.becomeFirstResponder()
    AnalyticsManager.setScreenName(name: ScreenName.loginMobileNumberScreen,
                                   className: NSStringFromClass(type(of: self)))
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    removeKeyboardObservers()
    
    super.viewWillDisappear(animated)
  }
  
  // MARK: - Private methods
  
  fileprivate func addBottomBorder(color: UIColor) {
    let bottomLine = CALayer()
    bottomLine.frame = CGRect(x: 0.0, y: countryCodeTextField.frame.height - 1, width: countryCodeTextField.frame.width, height: 1.0)
    bottomLine.backgroundColor = color.cgColor
    countryCodeTextField.borderStyle = UITextField.BorderStyle.none
    countryCodeTextField.layer.addSublayer(bottomLine)
  }
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .custom
    self.transitioningDelegate = self
    view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    addBottomBorder(color: UIColor.black)
  }
  
  fileprivate func isMobileNumberValid() -> Bool {
    return (mobileNumberTextField.text?.isNumber() == true && mobileNumberTextField.text?.count == 10)
  }
  
  // MARK: - IBActions
  
  @IBAction func submitButtonTapped(_ sender: UIButton) {
    view.endEditing(true)
    guard let countryCode = countryCodeTextField.text, countryCode.isEmpty == false else {
      addBottomBorder(color: UIColor.red)
      return
    }
      
    if let mobileNumber = mobileNumberTextField.text,
      isMobileNumberValid() {
      submitButton.showLoading()
      self.invokeSignIn(mobileNumber: "+91\(mobileNumber)")
      
    }
    else {
        mobileNumberTextField.setError(Localization.invalidMobileNo)
    }
  }
  
  @IBAction func whyNeededButtonTapped(_ sender: UIButton) {
    let vc = WhyLoginNeededViewController()
    self.present(vc, animated: true, completion: nil)
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
    
  //MARK:- Navigate to OTP Screen
    private func navigateToOTPScreen(mobileNumber:String){
        DispatchQueue.main.async {
            let otpVC = OtpVerificationViewController(mobileNumber: mobileNumber)
            self.present(otpVC, animated: true, completion: nil)
        }
    }
    
   //MARK:- Custom Login
    private func invokeSignIn(mobileNumber:String) {
        
        APIClient.sharedInstance.generateOTP(postDict: [Constants.ApiKeys.primaryIdMobile:mobileNumber]) {
            [weak self](data, error) in
            DispatchQueue.main.async {
                self?.submitButton.hideLoading()
            }
            if let error = error {
                self?.mobileNumberTextField.setError(Localization.genericSignInError)
              let params = ["screenName" : "LoginViewController",
                            "error" : error.localizedDescription]
              AnalyticsManager.logEvent(name: Events.getOtpFailed, parameters: params)
            }
            else{
                self?.navigateToOTPScreen(mobileNumber: mobileNumber)
              let params = ["screenName" : "LoginViewController"]
              AnalyticsManager.logEvent(name: Events.getOtp, parameters: params)
          }
        }
    }
  
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension LoginViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }

}


extension LoginViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == countryCodeTextField {
      addBottomBorder(color: UIColor.black)
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == mobileNumberTextField {
      let newLength = (textField.text ?? "").utf16.count + string.utf16.count - range.length
      return newLength <= mobileNumberFieldTextLimit
    }
    return true
  }
  
}

extension LoginViewController {
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
