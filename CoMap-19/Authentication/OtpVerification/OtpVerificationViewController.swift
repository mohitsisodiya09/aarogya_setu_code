//
//  OtpVerificationViewController.swift
//  CoMap-19
//
//
//

import UIKit

final class OtpVerificationViewController: UIViewController {
  
  // MARK: - Private variables
  
  fileprivate struct Defaults {
    static let statusPollingQueue = "com.as.statusPollingQueue"
  }
  
  fileprivate lazy var statusPollingQueue = DispatchQueue(label: Defaults.statusPollingQueue,
                                                          attributes: .concurrent)
  fileprivate var resendOtpTimer: Timer?
  fileprivate var timerCount = 0
  fileprivate var bgTask: UIBackgroundTaskIdentifier?
  
  fileprivate var mobileNumber: String!

  // MARL: - IBOutlets
  
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
      submitButton.setTitle(Localization.submit, for: .normal)
      submitButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
      submitButton.accessibilityLabel = AccessibilityLabel.submit
    }
  }
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      titleLabel.textColor = .black
      titleLabel.text = Localization.enterOtp
      titleLabel.accessibilityLabel = AccessibilityLabel.enterOtp
    }
  }
  
  @IBOutlet weak var subTitleLabel: UILabel! {
    didSet {
      subTitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
      subTitleLabel.textColor = .black
    }
  }
  
  @IBOutlet weak var containerView: RoundCorners!
  
  @IBOutlet weak var otpTextField: FloatingLabelTextField! {
    didSet {
      otpTextField.keyboardType = .numberPad
      otpTextField.placeholder = Localization.otp
      otpTextField.accessibilityLabel = AccessibilityLabel.otp
    }
  }
  
  @IBOutlet weak var resendOtpButton: UIButton! {
    didSet {
      resendOtpButton.setTitle(Localization.resendOtp, for: .normal)
      resendOtpButton.accessibilityLabel = AccessibilityLabel.resendOtp
    }
  }
  
  @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Initialization methods
  
  convenience init(mobileNumber: String) {
    self.init(nibName: "OtpVerificationViewController", bundle: nil)
    setupViewController()
    subTitleLabel.text = Localization.weHaveSentOtp
    self.mobileNumber = mobileNumber
    resendOtpButton.isHidden = true
    startResendTimer()
    subTitleLabel.text = String(format: Localization.weHaveSentOtp, mobileNumber)
    subTitleLabel.accessibilityLabel = String(format: AccessibilityLabel.weHaveSentOtp, mobileNumber)
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    AnalyticsManager.setScreenName(name: ScreenName.otpVerficationScreen,
                                   className: NSStringFromClass(type(of: self)))
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
  
  fileprivate func startResendTimer() {
    if resendOtpTimer == nil {
      timerCount = 30
      let app = UIApplication.shared
      
      weak var weakSelf = self
      bgTask = app.beginBackgroundTask(expirationHandler: {
        if weakSelf?.bgTask != .invalid {
          if let bgTask = weakSelf?.bgTask {
            app.endBackgroundTask(bgTask)
          }
          weakSelf?.bgTask = UIBackgroundTaskIdentifier.invalid
        }
      })
      
      resendOtpTimer = Timer(timeInterval: 1, target: self, selector: #selector(timerCalled(_:)), userInfo: nil, repeats: true)
      
      addCodeTextFieldRightView()
    }
    
    if let resendOtpTimer = resendOtpTimer {
      RunLoop.current.add(resendOtpTimer, forMode: .common)
    }
  }
  
  @objc fileprivate func timerCalled(_ timer: Timer?) {
    
    if timerCount == 0 {
      otpTextField.rightView = nil
      if let task = bgTask {
        UIApplication.shared.endBackgroundTask(task)
        bgTask = UIBackgroundTaskIdentifier.invalid
      }
      resendOtpButton.isHidden = false
      resendOtpTimer?.invalidate()
      resendOtpTimer = nil
    } else {
      setCodeTextFieldTimerCount()
      resendOtpButton.isHidden = true
    }
    
    timerCount -= 1
  }
  
  fileprivate func setCodeTextFieldTimerCount() {
    let timerText = String(format: "00:%02d", NSNumber(value: timerCount).intValue)
    let label = otpTextField.rightView as? UILabel
    label?.text = String(format: NSLocalizedString("Resend in %@", comment: ""), timerText)
    label?.sizeToFit()
    label?.frame = CGRect(x: 0, y: 0, width: 100.0, height: label?.bounds.size.height ?? 0.0)
    otpTextField.rightView = label
  }

  fileprivate func trackRegistrationEvent(_ longitude: String?, _ latitude: String?) {
    let params = ["screenName" : "OtpVerificationViewController"]
    AnalyticsManager.logEvent(name: Events.validateOtp, parameters: params)
    
    if longitude != nil && latitude != nil {
      let params = ["screenName" : "OtpVerificationViewController"]
      AnalyticsManager.logEvent(name: Events.registerWithLoc, parameters: params)
    }
    else {
      let params = ["screenName" : "OtpVerificationViewController"]
      AnalyticsManager.logEvent(name: Events.registerWithoutLoc, parameters: params)
    }
  }
  
  private func verifyOTPCustomFlow(confirmationCode:String) {
    APIClient.sharedInstance.validateOTP(postDict: [Constants.ApiKeys.primaryIdMobile:mobileNumber as Any, Constants.ApiKeys.passCodeKey:confirmationCode]) {[weak self] (json, error) in
      
      if let dict = json as? [String:Any],
        let accessToken = dict["auth_token"] as? String,
        let refreshToken = dict["refresh_token"] as? String {
        KeychainHelper.saveAwsToken(accessToken)
        KeychainHelper.saveRefreshToken(refreshToken)
        KeychainHelper.saveMobileNumber(self?.mobileNumber)
        
        APIClient.sharedInstance.authorizationToken = accessToken
        APIClient.sharedInstance.refreshToken = refreshToken
        
        if UserDefaults.standard.bool(forKey: Constants.UserDefault.isFirstLaunch) == false {
          UserDefaults.standard.set(true, forKey: Constants.UserDefault.isFirstLaunch)
        }
        
        UserDefaults.standard.set(true, forKey: "isUserAuthenticated")
        
        NotificationCenter.default.post(Notification(name: .login,
                                                     object: nil,
                                                     userInfo: nil))
        let location = DAOManagerImpl.shared.currentLocation
        var latitude, longitude: String?
        if let lat = location?.lat {
          latitude = String(format: "%f", lat)
        }
        if let long = location?.lon {
          longitude = String(format: "%f", long)
        }
        
        APIClient.sharedInstance.registerUser(name: "iOS User",
                                              macAddress: nil,
                                              fcmToken: UserDefaults.standard.string(forKey: Constants.UserDefault.fcmToken),
                                              lat: latitude,
                                              lon: longitude)
        { (responseObject, error) in
          
          self?.submitButton.hideLoading()
          
          DispatchQueue.main.async {
            self?.submitButton.hideLoading()
            
            if let _ = error {
              self?.otpTextField.setError(Localization.registrationFailed)
            }
            else if let responseObject = responseObject as? [String: Any],
              let data = responseObject["data"] as? [String: Any],
              let deviceId = data["did"] as? String {
              KeychainHelper.saveDeviceId(deviceId)
              
              self?.navigateToHome()
            }
            else {
              DispatchQueue.global(qos: .background).async {
                APIClient.sharedInstance.getUserStatus { (json, response, error) in
                  if let response = json as? [String: Any] {
                    if let deviceId = response["did"] as? String {
                      KeychainHelper.saveDeviceId(deviceId)
                    }
                    if let qrPublicKey = response[Constants.ApiKeys.qrPublicKey] as? String {
                      KeychainHelper.saveQrPublicKey(qrPublicKey)
                    }
                  }
                  else {
                    self?.scheduleStatusPolling()
                  }
                }
              }
              
              self?.navigateToHome()
              
            }
          }
          
        }
        
        self?.trackRegistrationEvent(longitude, latitude)
      }
      else if let dict = json as? [String: Any], let message = dict["message"] as? String {
        self?.handleOtpVerificationError(message: message)
      }
      else if let error = error {
        
        self?.handleOtpVerificationError(message: error.localizedDescription)
      }
      else {
        self?.handleOtpVerificationError(message: Localization.genericOTPError)
      }
      
    }
  }
  
  fileprivate func handleOtpVerificationError(message: String) {
    self.submitButton.hideLoading()
    self.otpTextField.setError(message)
    let params = ["screenName" : "OtpVerificationViewController",
                  "error" : message]
    AnalyticsManager.logEvent(name: Events.validateOtpFailed, parameters: params)
  }
  
  fileprivate func navigateToHome() {
    self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
  }
  
  fileprivate func addCodeTextFieldRightView() {
    let label = UILabel()
    label.font = UIFont(name: "AvenirNext-Regular", size: 12.0)
    label.textColor = UIColor.gray
    otpTextField.rightView = label
    otpTextField.rightViewMode = .always
  }
  
  fileprivate func scheduleStatusPolling() {
    
    statusPollingQueue.asyncAfter(deadline: .now() + 30) {
      self.pollStatus()
    }
  }
  
  fileprivate func pollStatus() {
    APIClient.sharedInstance.getUserStatus { (json, urlresponse, error) in
      if let response = json as? [String: Any],
        let deviceId = response["did"] as? String {
        KeychainHelper.saveDeviceId(deviceId)
      }
      else {
        self.scheduleStatusPolling()
      }
    }
    
  }
  
  // MARK: - IBActions
  
  @IBAction func submitButtonTapped(_ sender: UIButton) {
    //let verificationID = UserDefaults.standard.string(forKey: "authVerificationID"),
    if let otp = otpTextField.text {
      submitButton.showLoading()
      
      self.verifyOTPCustomFlow(confirmationCode: otp)
    }
    else {
      otpTextField.setError("Please enter OTP")
    }
  }
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func resendButtonTapped(_ sender: UIButton) {
    // stop timer
    
    self.otpTextField.setError(nil)
    self.otpTextField.text = nil
    
    APIClient.sharedInstance.generateOTP(postDict: [Constants.ApiKeys.primaryIdMobile:mobileNumber]) {
      [weak self](data, error) in
      if let _ = error {
        self?.otpTextField.setError(Localization.genericSignInError)
      }
      else{
        self?.startResendTimer()
      }
    }
    
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension OtpVerificationViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerBottomToTopDismiss()
  }
  
}

// MARK: - UIKeyboard observer methods

extension OtpVerificationViewController {

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
