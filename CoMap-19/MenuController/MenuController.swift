//
//  MenuController.swift
//  
//

//

import UIKit

enum MenuType {
  case profile
  case qrCode
  case pendingApproval
  case shareData
  case callHelpline
  case settings
  case privacyPolciy
  case terms
  case statusCheck
}

protocol MenuControllerDelegate: AnyObject {
  func hideMenuButtonTapped(_ sender: UIButton)
}

final class MenuController: UIViewController {
    
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
 
  @IBOutlet weak var appVersionLabel: UILabel! {
    didSet {
      appVersionLabel.font = UIFont(name: "AvenirNext-Medium", size: 14.0)
      appVersionLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    }
  }
    
  // MARK: - Public variables
  
  weak var delegate: MenuControllerDelegate?
  
  // MARK: - Private variables
  
  fileprivate var rowLayout = [MenuType]()
  
  // MARK: - View Life cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setAppVersionLabel()
    prepareTableView()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(languageChanged),
                                           name: .languageChanged,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(nameSaved),
                                           name: .nameSaved,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                              selector: #selector(requestStatusChanged),
                                              name: .requestStatusChanged,
                                              object: nil)
  }
  
  deinit {
     NotificationCenter.default.removeObserver(self,
                                               name: .languageChanged,
                                               object: nil)
    NotificationCenter.default.removeObserver(self,
                                              name: .nameSaved,
                                              object: nil)
    NotificationCenter.default.removeObserver(self,
                                                name: .requestStatusChanged,
                                                object: nil)
  }
  
  // MARK: - Private methods
  
  fileprivate func setAppVersionLabel() {
    if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
      appVersionLabel.text = String(format: "%@ %@", Localization.appVersion, appVersion)
      appVersionLabel.isHidden = false
    }
    else {
      appVersionLabel.isHidden = true
    }
  }
  
  fileprivate func prepareTableView() {
    prepareTableViewLayout()
    registerTableViewCells()
    
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none
    
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  fileprivate func registerTableViewCells() {
    tableView.register(UINib(nibName: String(describing: MenuTableViewCell.self),
                             bundle: nil), forCellReuseIdentifier: String(describing: MenuTableViewCell.self))
    
    tableView.register(UINib(nibName: String(describing: TermsTableViewCell.self),
                             bundle: nil), forCellReuseIdentifier: String(describing: TermsTableViewCell.self))
   
    tableView.register(UINib(nibName: String(describing: ProfileTableViewCell.self),
                             bundle: nil), forCellReuseIdentifier: String(describing: ProfileTableViewCell.self))
  }
  
  fileprivate func prepareTableViewLayout() {
    if KeychainHelper.getMobileNumber() != nil || KeychainHelper.getName() != nil {
      rowLayout.append(.profile)
    }
    
    rowLayout.append(contentsOf: [.qrCode, .statusCheck, .pendingApproval, .shareData, .callHelpline, .settings, .privacyPolciy, .terms])
  }
  
  fileprivate func getRowType(_ indexPath: IndexPath) -> MenuType {
     return rowLayout[indexPath.row]
   }
  
  fileprivate func openWebView(target: String) {
    let webVC = WebViewController()
    webVC.urlString = target
    let navController = UINavigationController(rootViewController: webVC)
    navController.modalPresentationStyle = .overFullScreen
    self.present(navController, animated: false, completion: nil)
  }
  
  fileprivate func openApplication(urlString: String) {
    if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }
  
  fileprivate func shareBluetoothData() {
    if RemoteConfigManager.shared.getBoolValueFor(key: RemoteConfigKeys.disableSyncChoice) == true {
      pushUploadStatusVC(sourceType: .selfConsent)
    }
    else {
      let uploadDataConsentScreen = UploadDataConsentViewController()
      uploadDataConsentScreen.delegate = self
      self.present(uploadDataConsentScreen, animated: true, completion: nil)
    }
  }
  
  fileprivate func pushUploadStatusVC(sourceType: UploadDataStatusSourceType) {
    let uploadStatusVC = UploadDataStatusViewController()
    uploadStatusVC.sourceType = sourceType
    self.present(uploadStatusVC, animated: true, completion: nil)
  }
  
  @objc fileprivate func languageChanged(notification: NSNotification) {
    tableView.reloadData()
  }
  
  @objc fileprivate func backButtonTapped() {
    self.presentedViewController?.dismiss(animated: true, completion: nil)
  }
  
  @objc fileprivate func nameSaved(notification: NSNotification) {
    tableView.reloadData()
  }
  
  @objc fileprivate func requestStatusChanged(notification: NSNotification) {
     tableView.reloadData()
   }
  
  // MARK: - Actions

  @IBAction func hideMenuButtonTapped(_ sender: UIButton) {
    delegate?.hideMenuButtonTapped(sender)
  }
}

// MARK: - UITableViewDelegate methods

extension MenuController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let rowType = getRowType(indexPath)
    
    switch rowType {
    
    case .privacyPolciy:
      openWebView(target: Constants.WebUrl.privacyPage)
      
    case .terms:
      openWebView(target: Constants.WebUrl.tncPage)
    
    case .callHelpline:
      openApplication(urlString: Constants.telephoneHelplineURL)
      
    case .shareData:
      shareBluetoothData()
      
    case .qrCode:
      let qrCodeVC = QRCodeViewController()
      qrCodeVC.modalPresentationStyle = .fullScreen
      self.present(qrCodeVC, animated: true, completion: nil)
      
    case .pendingApproval:
      let pendingApprovalVC = PendingApprovalViewController()
      let navController = UINavigationController(rootViewController: pendingApprovalVC)
      navController.modalPresentationStyle = .fullScreen
      let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_icon").withRenderingMode(.alwaysOriginal),
                                       style: .plain,
                                       target: self,
                                       action: #selector(backButtonTapped))
      pendingApprovalVC.navigationItem.setLeftBarButton(backButton, animated: false)
      self.present(navController, animated: true, completion: nil)
      
    case .settings:
      let storyboard = UIStoryboard(name: Constants.Storyboard.main, bundle: nil)
      let settingsVC = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.settingsScreen)
      let root = UINavigationController(rootViewController: settingsVC)
      root.modalPresentationStyle = .overFullScreen
      self.present(root, animated: true, completion: nil)
      
    case .statusCheck:
      let statusCheckVC = StatusCheckViewController()
      let navC = UINavigationController(rootViewController: statusCheckVC)
      navC.modalPresentationStyle = .fullScreen
      self.present(navC, animated: true, completion: nil)
      
    default:
      break
    }
  }
}

// MARK: - UITableViewDataSource methods

extension MenuController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowLayout.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let rowType = getRowType(indexPath)
    
    switch rowType {
      
    case .shareData:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell")! as! MenuTableViewCell
     
      cell.configure(title: Localization.shareDataWithGov,
                     subtitle: Localization.shareDataPositive,
                     iconName: "upload_warning_icon")
      return cell
      
    case .callHelpline:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell")! as! MenuTableViewCell
      
      cell.configure(title: Localization.callHelpline,
                     subtitle: Localization.healthMinistryTollFree,
                     iconName: "call_helpline")
      return cell
      
    case .qrCode:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell")! as! MenuTableViewCell
      
      cell.configure(title: Localization.qrCode,
                     subtitle: nil,
                     iconName: "qr_code")
      return cell
      
    case .terms:
      let cell = tableView.dequeueReusableCell(withIdentifier: "TermsTableViewCell")! as! TermsTableViewCell
      cell.configure(title: Localization.termsUse)
      return cell
      
    case .settings:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell")! as! MenuTableViewCell
      
      cell.configure(title: Localization.settings,
                     subtitle: nil,
                     iconName: "settings")
      return cell
      
    case .privacyPolciy:
      let cell = tableView.dequeueReusableCell(withIdentifier: "TermsTableViewCell")! as! TermsTableViewCell
      cell.configure(title: Localization.privacyPolicy)
      return cell
      
    case .profile:
      let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell")! as! ProfileTableViewCell
      cell.configure(name: KeychainHelper.getName(), mobileNumber: KeychainHelper.getMobileNumber())
      cell.selectionStyle = .none
      return cell
    
    case .pendingApproval:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell")! as! MenuTableViewCell
      
      let pendingRequestsCount = StatusApprovalRequestManager.shared.pendingRequestCount
      let count =  pendingRequestsCount == 0 ? nil : String(format: " %d", pendingRequestsCount)
      
      cell.configure(title: Localization.approvals,
                     subtitle: nil,
                     iconName: "approvals_icon",
                     count: count)
      return cell
      
    case .statusCheck:
      let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell")! as! MenuTableViewCell
      
      cell.configure(title: Localization.statusCheck,
                     subtitle: Localization.keepACheckOnStatus,
                     iconName: "status_check")
      return cell
    }
    
  }
}

// MARK: - UploadDataConsentViewControllerDelegate methods implementations

extension MenuController: UploadDataConsentViewControllerDelegate {

  func uploadDataConsentViewController(_ vc: UploadDataConsentViewController, beingTestedButtonTapped button: UIButton) {
    self.dismiss(animated: true) {
      self.pushUploadStatusVC(sourceType: .beingTested)
    }
  }
  
  func uploadDataConsentViewController(_ vc: UploadDataConsentViewController, testedPositiveButtonTapped button: UIButton) {
    self.dismiss(animated: true) {
      self.pushUploadStatusVC(sourceType: .testedPositive)
    }
  }
  
  func uploadDataConsentViewController(_ vc: UploadDataConsentViewController, closeButtonTapped button: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
}
