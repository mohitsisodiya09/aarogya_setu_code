//
//  ScanOrCodeViewController.swift
//  CoMap-19
//

//
//

import UIKit
import AVFoundation
import SVProgressHUD

final class ScanOrCodeViewController: UIViewController {
  
  // MARK: - IBOutlets
  @IBOutlet weak var generateMyOrCodeButton: UIButton! {
    didSet {
      generateMyOrCodeButton.setTitle(Localization.generateMyQrCode, for: .normal)
      generateMyOrCodeButton.layer.cornerRadius = Defaults.generateMyOrCodeButtonCornerRadius
      generateMyOrCodeButton.layer.borderWidth = Defaults.generateMyOrCodeButtonBorderWidth
      generateMyOrCodeButton.layer.borderColor = UIColor.white.cgColor
    }
  }
  
  @IBOutlet weak var scanQrPrompt: UILabel! {
    didSet {
      scanQrPrompt.text = Localization.scanQrPrompt
    }
  }
  
  @IBOutlet weak var cameraPreviewContainerView: UIView!
  @IBOutlet weak var qrAreaOfInterestView: UIView!
  
  @IBOutlet weak var toolTipTitleLabel: UILabel! {
    didSet {
      toolTipTitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 18.0)
    }
  }
  
  @IBOutlet weak var toolTipSubtitleLabel: UILabel! {
    didSet {
      toolTipSubtitleLabel.textColor = .white
    }
  }
  @IBOutlet weak var toolTipView: TooltipView! {
    didSet {
      toolTipView.isHidden = true
    }
  }
  @IBOutlet weak var tooltipButton: UIButton!
  
  // MARK: - Private members
  private var permission:Permission!
  
  private struct Defaults {
    static let generateMyOrCodeButtonCornerRadius: CGFloat = 22.0
    static let generateMyOrCodeButtonBorderWidth: CGFloat = 2.0
    static let qrAreaOfInterestViewBorderWidth: CGFloat =  2.0
    static let qrAreaOfInterestViewCornerRadius: CGFloat =  10.0
  }
  
  private var captureSession:AVCaptureSession = AVCaptureSession()
  private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
  private var qrCodeFrameView:UIView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    permission = Permission(viewController: self)
    
    qrAreaOfInterestView.layer.cornerRadius = Defaults.qrAreaOfInterestViewCornerRadius
    qrAreaOfInterestView.layer.borderWidth = Defaults.qrAreaOfInterestViewBorderWidth
    qrAreaOfInterestView.layer.borderColor = UIColor.white.cgColor
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    permission.requestCamera { [weak self] (status) in
      DispatchQueue.main.async {
        if status { self?.setupCameraPreview() }
      }
    }
  }
    
  // MARK: - Private methods
  
  private func setupCameraPreview() {
    // Get the back-facing camera for capturing videos
    
    guard videoPreviewLayer == nil else { return }
    
    let deviceDiscoverySession = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)

    guard let captureDevice = deviceDiscoverySession else {
      return
    }
    
    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous device object.
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Set the input device on the capture session.
      captureSession.addInput(input)
      
    } catch {
      return
    }
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    let captureMetadataOutput = AVCaptureMetadataOutput()
    captureSession.addOutput(captureMetadataOutput)
    
    // Set delegate and use the default dispatch queue to execute the call back
    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    videoPreviewLayer?.frame = view.layer.bounds
    
    guard let previewLayer = videoPreviewLayer else { return }
    
    cameraPreviewContainerView.layer.addSublayer(previewLayer)
    
    // Start video capture.
    captureSession.startRunning()
  }
  
  fileprivate func setQrCodeExpiredUI() {
    //QR expired
    toolTipView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.9568627451, blue: 0.9098039216, alpha: 1)
    toolTipView.borderColor = .white
    
    toolTipTitleLabel.text = Localization.expiredQrCode
    toolTipTitleLabel.isHidden = false
    toolTipTitleLabel.textColor = #colorLiteral(red: 0.8922759295, green: 0.5633923411, blue: 0, alpha: 1)
    
    toolTipSubtitleLabel.text = Localization.pleaseRequestThePersonToGenerateNewCode
    toolTipSubtitleLabel.textColor = .black
    toolTipSubtitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    
    tooltipButton.setImage(UIImage(named: "icCircularcloseGrey"), for: .normal)
    
    toolTipView.layoutIfNeeded()
  }
  
  fileprivate func setNonEnglishLangQrUI(payload: QrPayload) {
    // set delegate nil here
    switch HealthStatus.getStatusForCode(payload.statusCode) {
    case .low:
      toolTipSubtitleLabel.text = String(format: Localization.lowRiskOfInfection,
                                         subTitleString(name: payload.fullName, phoneNumber: payload.mobileNumber))
    case .moderate:
      toolTipSubtitleLabel.text = String(format: Localization.moderateRiskOfInfection,
                                         subTitleString(name: payload.fullName, phoneNumber: payload.mobileNumber))
    case .high:
      toolTipSubtitleLabel.text = String(format: Localization.highRiskOfInfection,
                                         subTitleString(name: payload.fullName, phoneNumber: payload.mobileNumber))
    case .testedPositive:
      toolTipSubtitleLabel.text = String(format: Localization.testedPositiveForCovid19,
                                         subTitleString(name: payload.fullName, phoneNumber: payload.mobileNumber))
    default:
       toolTipSubtitleLabel.text = payload.message
    }
  }
  
  fileprivate func setEngLangQrUI(payload: QrPayload) {
    toolTipSubtitleLabel.text = payload.message
  }
  
  private func viewUserHealthStatus(payload: QrPayload) {
    
    let qrDate = Date(timeIntervalSince1970: payload.expirationTimeStamp)
    if qrDate < Date() {
      setQrCodeExpiredUI()
    }
    else {
      toolTipView.borderColor = .white
      toolTipTitleLabel.isHidden = true
      
      if let lang = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String,
         let langRaw = Language(rawValue: lang), langRaw != .english {
        setNonEnglishLangQrUI(payload: payload)
      }
      else {
        setEngLangQrUI(payload: payload)
      }
      toolTipView.backgroundColor = payload.colorCode?.hexStringToUIColor()
    
      toolTipSubtitleLabel.textColor = .white
      toolTipSubtitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 16.0)
      
      tooltipButton.setImage(UIImage(named: "icCircularcloseWhite"), for: .normal)
    }
    
    toolTipView.isHidden = false
    toolTipView.layoutIfNeeded()
  }
  
  private func viewQrInvalidToolTip() {
    
    toolTipView.backgroundColor = #colorLiteral(red: 0.9960784314, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
    
    toolTipView.borderColor = .red
    
    toolTipTitleLabel.text = Localization.invalidQrCode
    toolTipTitleLabel.isHidden = false
    toolTipTitleLabel.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    
    toolTipSubtitleLabel.text = Localization.notGeneratedByOfficialApp
    toolTipSubtitleLabel.textColor = .black
    toolTipSubtitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    
    tooltipButton.setImage(UIImage(named: "icCircularcloseGrey"), for: .normal)
    
    toolTipView.isHidden = false
    toolTipView.layoutIfNeeded()
  }
  
  private func subTitleString(name: String?, phoneNumber: String) -> String {
    if let name = name {
      return String(format: "%@ (%@)", name, phoneNumber)
    }
    else {
      return String(format: "(%@)", phoneNumber)
    }
  }
  
  private func handleReadQrCodeFailure(qrMetaData string: String) {
    SVProgressHUD.show()
    
    captureSession.stopRunning()
    
    APIClient.sharedInstance.getQrPublicKey { [weak self] (responseObject, _, error) in
      SVProgressHUD.dismiss()
      
      DispatchQueue.main.async {
        if let error = error {
          ToastView.showToastMessage(error.localizedDescription)
          self?.captureSession.startRunning()
          return
        }
        
        if let responseDict = responseObject as? [String: Any],
          let publicKey = responseDict["data"] as? String {
          KeychainHelper.saveQrPublicKey(publicKey)
          
          guard let jwt = JWTDecoding(token: string, publicKey: publicKey) else {
            self?.viewQrInvalidToolTip()
            return
          }
          
          self?.handleReadQrCodeSuccess(jwt)
        }
      }
    }
  }
  
  private func handleReadQrCodeSuccess(_ jwt: JWTDecoding) {
    do {
      let data = try JSONSerialization.data(withJSONObject: jwt.payloadDict(), options: .prettyPrinted)
      let qrPayload = try JSONDecoder().decode(QrPayload.self, from: data)
      viewUserHealthStatus(payload: qrPayload)
      captureSession.stopRunning()
    }
    catch {
      ToastView.showToastMessage(error.localizedDescription)
      captureSession.startRunning()
    }
  }
  
  // MARK: - Button Actions
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func generateMyOrCodeButtonTapped(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func toolTipButtonTapped(_ sender: UIButton) {
    captureSession.startRunning()
    toolTipView.isHidden = true
  }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanOrCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    // Check if the metadataObjects array is not nil and it contains at least one object.
   
    if metadataObjects.count == 0 {
     // qrCodeFrameView?.frame = CGRect.zero
      debugPrint("No QR code is detected")
      return
    }
    
    // Get the metadata object.
    guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
    
    if metadataObj.type == AVMetadataObject.ObjectType.qr {
      // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds
      
      if let metaDataString = metadataObj.stringValue {
        
        guard let publicKey = KeychainHelper.getQrPublicKey(),
          let jwt = JWTDecoding(token: metaDataString, publicKey: publicKey) else {
            return handleReadQrCodeFailure(qrMetaData: metaDataString)
        }
        
        self.handleReadQrCodeSuccess(jwt)
      }
    }
  }
  
}
