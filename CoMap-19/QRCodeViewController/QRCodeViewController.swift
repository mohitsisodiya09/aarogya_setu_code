//
//  QRCodeViewController.swift
//  CoMap-19
//

//
//

import UIKit
import SVProgressHUD

final class QRCodeViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var fullNameLabel: UILabel!
  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var qrCodeImageView: UIImageView!
  
  @IBOutlet weak var tapToRefreshQrCodeView: UIView! {
    didSet {
      tapToRefreshQrCodeView.layer.cornerRadius = Defaults.tapToRefreshQrCodeViewCornerRadius
      tapToRefreshQrCodeView.layer.borderWidth = Defaults.tapToRefreshQrCodeViewBorderWidth
      tapToRefreshQrCodeView.layer.borderColor = #colorLiteral(red: 0.9467981458, green: 0.9469191432, blue: 0.9499695897, alpha: 1).cgColor
    }
  }
  
  @IBOutlet weak var scanQrCodeButton: UIButton! {
    didSet {
      scanQrCodeButton.setTitle(Localization.scanQrCode, for: .normal)
      scanQrCodeButton.layer.cornerRadius = Defaults.scanQrCodeButtonCornerRadius
      scanQrCodeButton.layer.borderWidth = Defaults.scanQrCodeButtonBorderWidth
      scanQrCodeButton.layer.borderColor = #colorLiteral(red: 0.1875338256, green: 0.209551245, blue: 0.2606954277, alpha: 1).cgColor
    }
  }
  
  @IBOutlet weak var refreshQrCodeLabel: UILabel!
  @IBOutlet weak var scanQrToGetMyHealthStatusLabel: UILabel!
  
  @IBOutlet weak var qrCodeValidForLabel: UILabel! {
    didSet {
      qrCodeValidForLabel.text = Localization.qrCodeValidFor
    }
  }
  @IBOutlet weak var qrCodeValidForMinutesLabel: UILabel!
  @IBOutlet weak var qrCodeValidStackView: UIStackView!
  
  // MARK: - Private members
  
  private struct Defaults {
    static let scanQrCodeButtonCornerRadius: CGFloat = 22.0
    static let scanQrCodeButtonBorderWidth: CGFloat = 2.0
    static let tapToRefreshQrCodeViewCornerRadius: CGFloat = 76.0
    static let tapToRefreshQrCodeViewBorderWidth: CGFloat = 2.0
    
    static let scanQrToGetMyHealthStatusLabelSuccessColor: UIColor = #colorLiteral(red: 0.1875338256, green: 0.209551245, blue: 0.2606954277, alpha: 1)
    static let scanQrToGetMyHealthStatusLabelFailureColor: UIColor = #colorLiteral(red: 0.9615393281, green: 0.4819539785, blue: 0.5206862092, alpha: 1)
  }
  
  private lazy var qrOverlayImageView = UIImageView(image: UIImage(named: "qrLogo"))
  private var expTimer: Timer?
  private var secondsLeftForQrExpiration: Int = 0
  
  // MARK: - Lifecycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    onViewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(fetchQr), name: UIApplication.willEnterForegroundNotification, object: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    expTimer?.invalidate()
  }
  
  // MARK: - Button Actions
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func scanQrCodeButtonTapped(_ sender: UIButton) {
    let scanQrCodeVC = ScanOrCodeViewController()
    scanQrCodeVC.modalPresentationStyle = .overFullScreen
    self.present(scanQrCodeVC, animated: true, completion: nil)
  }
  
  // MARK: - Private methods
  private func onViewDidLoad() {
     addTapActionToRefreshQrCodeView()
     addTapActionToRefreshQrLabel()

    showSavedQrCodeIfValid()
  }

  fileprivate func showSavedQrCodeIfValid() {
    SVProgressHUD.show()
    
    DispatchQueue.global(qos: .userInitiated).async {
      if let qrMetaData = KeychainHelper.getQrMetaData() {
        
        let payload = JWTDecoding.decodePayload(jwtToken: qrMetaData)
        
        SVProgressHUD.dismiss()
        
        DispatchQueue.main.async {
          do {
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            let qrPayload = try JSONDecoder().decode(QrPayload.self, from: data)
            
            if Date(timeIntervalSince1970: qrPayload.expirationTimeStamp) > Date(),
              Permission.isLocationOn(),
              Permission.isBluetoothOn() {
              
              self.handleQrCodeSuccess(response: qrMetaData)
            }
            else {
              KeychainHelper.removeQrMetaData()
              self.fetchQr()
            }
          }
          catch {
            KeychainHelper.removeQrMetaData()
            self.fetchQr()
          }
        }
        
      }
      else {
        DispatchQueue.main.async {
          self.fetchQr()
        }
      }
    }
  }
  
  private func addTapActionToRefreshQrCodeView() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToRefreshQrCodeViewTapped))
    tapToRefreshQrCodeView.addGestureRecognizer(tapGesture)
  }
  
  @objc private func tapToRefreshQrCodeViewTapped() {
    fetchQr()
  }
  
  private func addTapActionToRefreshQrLabel() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(refreshQrCodeLabelTapped))
    refreshQrCodeLabel.addGestureRecognizer(tapGesture)
  }
  
  @objc private func refreshQrCodeLabelTapped() {
    
    if Permission.isLocationOn() && Permission.isBluetoothOn() {
      fetchQr()
    }
    else {
      guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
      UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
  }
  
  /**
   * Get QR Encoded String Request
   */
  
  @objc private func fetchQr() {
      
    if Permission.isLocationOn() && Permission.isBluetoothOn() {
      getQrCode()
    }
    else if !Permission.isLocationOn() && !Permission.isBluetoothOn() {
      handleQrCodeFailure(title: Localization.toGenerateQrBleAndGpsMustBeON, subtitle: Localization.turnOnBleAndGps)
    }
    else if !Permission.isLocationOn() {
      handleQrCodeFailure(title: Localization.toGenerateQrBleAndGpsMustBeON, subtitle: Localization.turnOnGps)
    }
    else if !Permission.isBluetoothPermissionAllowed() {
      handleQrCodeFailure(title: Localization.toGenerateQrBleAndGpsMustBeON, subtitle: Localization.turnOnBle)
    }
    else {
      #if targetEnvironment(simulator)
        getQrCode()
      #else
        handleQrCodeFailure(title: Localization.toGenerateQrBleAndGpsMustBeON, subtitle: Localization.turnOnBle)
        refreshQrCodeLabel.isHidden = true
      #endif
    }
  }
  
  private func getQrCode() {
    SVProgressHUD.show()
    
    APIClient.sharedInstance.getQrCode { [weak self] (responseObject, response, error) in
      SVProgressHUD.dismiss()
      
      guard let self  = self else { return }
      
      if let response = response as? HTTPURLResponse, response.statusCode == 401 {
        AWSAuthentication.sharedInstance.refreshAccessToken { [weak self] (success) in
          if success {
            self?.getQrCode()
          }
        }
      }
      else {
        
        DispatchQueue.main.async { [weak self] in
          if error != nil {
            self?.handleQrCodeFailure(title: Localization.toGenerateQrBleAndGpsMustBeON, subtitle: Localization.refreshQrCode)
            return
          }
          
          if let json = responseObject as? [String: Any],
            let response = json["data"] as? String {
            self?.handleQrCodeSuccess(response: response)
          }
        }
      }
    }
  }
  
  /**
   * Generate QR From Encoded String
   */
  private func generateQrCode(_ string: String) -> UIImage? {
    let data = string.data(using: .ascii)
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    qrFilter.setValue(data, forKey: "inputMessage")
    guard let qrImage = qrFilter.outputImage else { return nil }
    let transform = CGAffineTransform(scaleX: 10, y: 10)
    let scaledQrImage = qrImage.transformed(by: transform)
    
    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil }
    return UIImage(cgImage: cgImage)
  }
  
  /**
   * Add AppLogo Overlay to QR Code
   */
  private func addQrOverlay() {
    qrOverlayImageView.translatesAutoresizingMaskIntoConstraints = false
    qrOverlayImageView.contentMode = .center
    
    qrCodeImageView.addSubview(qrOverlayImageView)
    
    let centerXConst = NSLayoutConstraint(item: qrOverlayImageView, attribute: .centerX, relatedBy: .equal, toItem: qrCodeImageView, attribute: .centerX, multiplier: 1, constant: 0)
    let centerYConst = NSLayoutConstraint(item: qrOverlayImageView, attribute: .centerY, relatedBy: .equal, toItem: qrCodeImageView, attribute: .centerY, multiplier: 1, constant: 0)
    NSLayoutConstraint.activate([centerXConst, centerYConst])
  }
  
  /**
   * Fetch QR Success Handler
   */
  private func handleQrCodeSuccess(response: String) {
    tapToRefreshQrCodeView.isHidden = true
    
    refreshQrCodeLabel.text = Localization.refreshQrCode
    scanQrToGetMyHealthStatusLabel.text = Localization.scanQrCodeToGetMyHealthStatus
    scanQrToGetMyHealthStatusLabel.textColor = Defaults.scanQrToGetMyHealthStatusLabelSuccessColor
    
    qrOverlayImageView.removeFromSuperview()

    guard let publicKey = KeychainHelper.getQrPublicKey(),
      let jwt = JWTDecoding(token: response, publicKey: publicKey) else {
        return
    }
    
    KeychainHelper.saveQrMetaData(response)
    
    if let qrCodeImage = generateQrCode(response) {
      qrCodeImageView.image = qrCodeImage
      addQrOverlay()
    }
    
    do {
      let data = try JSONSerialization.data(withJSONObject: jwt.payloadDict(), options: .prettyPrinted)
      let qrPayload = try JSONDecoder().decode(QrPayload.self, from: data)
      setupUI(payload: qrPayload)
    }
    catch {
      ToastView.showToastMessage(error.localizedDescription)
    }
  }
  
  /**
   * Populate name, phoneNumber
   */
  private func setupUI(payload: QrPayload) {
    
    if let name = payload.fullName {
      KeychainHelper.saveName(name)
      fullNameLabel.text = name
      fullNameLabel.isHidden = false
      NotificationCenter.default.post(name: .nameSaved, object: nil)
    }
    else {
      fullNameLabel.isHidden = true
    }

    phoneNumberLabel.text = payload.mobileNumber
    phoneNumberLabel.isHidden = false

    setupQrExpTimeHandler(payload.expirationTimeStamp)
  }
  
  /**
   * Setup expiration timer
   */
  private func setupQrExpTimeHandler(_ expirationTimeStamp: Double) {
    let expDate = Date(timeIntervalSince1970: expirationTimeStamp)
    secondsLeftForQrExpiration = expDate.seconds(from: Date())
    updateQrValidTimeLabel(secondsLeftForQrExpiration)
    qrCodeValidStackView.isHidden = false
    
    expTimer?.invalidate()
    expTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
  }
  
  /**
   * Update timer value
   */
  @objc private func updateTimer() {
    secondsLeftForQrExpiration = secondsLeftForQrExpiration - 1
    
    if secondsLeftForQrExpiration <= 0 {
      expTimer?.invalidate()
      handleQrCodeFailure(title: Localization.qrCodeIsExpired, subtitle: Localization.refreshQrCode)
    } else {
      updateQrValidTimeLabel(secondsLeftForQrExpiration)
    }
  }
  
  func updateQrValidTimeLabel(_ secondsLeft: Int) {
    let seconds = secondsLeftForQrExpiration % 60
    let min: Int = secondsLeftForQrExpiration / 60
    
    if seconds == 0 {
      qrCodeValidForMinutesLabel.text = String(format: "%ld mins", min)
    }
    else {
      qrCodeValidForMinutesLabel.text = String(format: "%ld mins %ld sec", min, seconds)
    }
  }
    
  /**
  * Fetch QR Failure Handler
  */
  private func handleQrCodeFailure(title: String, subtitle: String) {
    tapToRefreshQrCodeView.isHidden = false
    
    qrCodeValidStackView.isHidden = true
    
    qrCodeImageView.image = UIImage(named: "qrCodePlaceholder")
    
    scanQrToGetMyHealthStatusLabel.text = title
    scanQrToGetMyHealthStatusLabel.textColor = Defaults.scanQrToGetMyHealthStatusLabelFailureColor
    
    refreshQrCodeLabel.text = subtitle
  }
}
