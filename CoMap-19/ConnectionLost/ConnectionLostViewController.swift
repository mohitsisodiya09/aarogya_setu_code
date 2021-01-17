//
//  ConnectionLostViewController.swift
//  CoMap-19
//
//
//

import UIKit

protocol ConnectionLostViewControllerDelegate: class {
  func tryAgainTapped()
  func settingsTapped()
}

enum ConnectionLostSourceType {
  case internet
  case location
  case bluetooth
}

class ConnectionLostViewController: UIViewController {
  
  @IBOutlet weak var shadowContainerView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = Localization.internetConnectionLost
      titleLabel.accessibilityLabel = AccessibilityLabel.internetConnectionLost
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.text = Localization.makeSureYourPhoneIsConnectedToWifi
      subtitleLabel.accessibilityLabel = AccessibilityLabel.makeSureYourPhoneIsConnectedToWifi
    }
  }
  
  @IBOutlet weak var tryAgainButton: UIButton! {
    didSet {
      tryAgainButton.setTitle(Localization.tryAgain, for: .normal)
      tryAgainButton.accessibilityLabel = AccessibilityLabel.tryAgain
    }
  }
  
  @IBOutlet weak var settingsButton: UIButton! {
    didSet {
      settingsButton.setTitle(Localization.settings, for: .normal)
      settingsButton.accessibilityLabel = AccessibilityLabel.settings
      settingsButton.layer.borderWidth = 1
      settingsButton.layer.borderColor = #colorLiteral(red: 0.6571614146, green: 0.6571771502, blue: 0.6571686864, alpha: 1)
    }
  }
  
  weak var delegate: ConnectionLostViewControllerDelegate?
  
  var sourceType: ConnectionLostSourceType = .internet
  
  convenience init() {
    self.init(nibName: "ConnectionLostViewController", bundle: nil)
    setupViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    shadowContainerView.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
    shadowContainerView.layer.shadowOpacity = 1
    shadowContainerView.layer.shadowOffset = .zero
    //shadowContainerView.layer.shadowRadius = 10
    
    switch sourceType {
    case .bluetooth:
      setTextForBluetooth()
    case .location:
      setTextForLocation()
    case .internet:
      setTextForInternet()
    }
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UIView.animate(withDuration: 1.0) { [weak self] in
      self?.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
  }
    
    fileprivate func setTextForLocation(){
        tryAgainButton.setTitle(Localization.turnOnText, for: .normal)
        settingsButton.setTitle(Localization.laterText, for: .normal)
        titleLabel.text = Localization.locationAlertTitle
        subtitleLabel.text = Localization.locationAlertSubTitle
        imageView.image = UIImage.init(named: "location")
      
        tryAgainButton.accessibilityLabel = AccessibilityLabel.turnOnText
        settingsButton.accessibilityLabel = AccessibilityLabel.laterText
        titleLabel.accessibilityLabel = AccessibilityLabel.locationAlertTitle
        subtitleLabel.accessibilityLabel = AccessibilityLabel.locationAlertSubTitle
    }
    
    fileprivate func setTextForBluetooth(){
        tryAgainButton.setTitle(Localization.turnOnText, for: .normal)
        settingsButton.setTitle(Localization.laterText, for: .normal)
        titleLabel.text = Localization.bluetoothAlertTitle
        subtitleLabel.text = Localization.bluetoothAlertSubTitle
        imageView.image = UIImage.init(named: "bluetooth")
      
        tryAgainButton.accessibilityLabel = AccessibilityLabel.turnOnText
        settingsButton.accessibilityLabel = AccessibilityLabel.laterText
        titleLabel.accessibilityLabel = AccessibilityLabel.bluetoothAlertTitle
        subtitleLabel.accessibilityLabel = AccessibilityLabel.bluetoothAlertSubTitle
    }
  
  fileprivate func setTextForInternet(){
       tryAgainButton.setTitle(Localization.tryAgain, for: .normal)
       settingsButton.setTitle(Localization.settings, for: .normal)
       titleLabel.text = Localization.internetConnectionLost
       subtitleLabel.text = Localization.makeSureYourPhoneIsConnectedToWifi
       imageView.image = UIImage.init(named: "connection_lost")
   }
  
  // MARK: - Private methods
  
  fileprivate func setupViewController() {
    self.modalPresentationStyle = .overFullScreen
  }
  
  // MARK: - Button Actions
  
  @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
    delegate?.tryAgainTapped()
  }
  
  @IBAction func settingsButtonTapped(_ sender: UIButton) {
    delegate?.settingsTapped()
  }
  
}
