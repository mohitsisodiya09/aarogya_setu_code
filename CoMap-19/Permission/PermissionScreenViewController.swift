//
//  PermissionScreenViewController.swift
//  CoMap-19
//
//
//

import UIKit

class PermissionScreenViewController: UIViewController {
    
  private var permission:Permission!
  lazy var subtitles = [Localization.setsYourLocation, Localization.monitorsYourDevice, Localization.dataWillBeSentOnlyToMoi]
  var titles = [Localization.deviceLocation, Localization.bluetooth, Localization.dataSharingWithMoh]
  
  lazy var accessibilitySubtitles = [AccessibilityLabel.setsYourLocation,
                                     AccessibilityLabel.monitorsYourDevice,
                                     AccessibilityLabel.dataWillBeSentOnlyToMoi]
  var accessibilityTitles: [String] = [AccessibilityLabel.deviceLocation,
                                       AccessibilityLabel.bluetooth,
                                       AccessibilityLabel.dataSharingWithMoh]
    
  @IBOutlet weak var submitButton: UIButton! {
    didSet {
      submitButton.setTitleColor(.white, for: .normal)
      submitButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      submitButton.layer.cornerRadius = submitButton.bounds.size.height/2
      submitButton.setTitle(Localization.contributeToASaferIndia, for: .normal)
      submitButton.accessibilityLabel = AccessibilityLabel.contributeToASaferIndia
    }
  }
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.separatorStyle = .none
    }
  }
  
  private struct Defaults {
    static let shareAppButtonWidth: CGFloat = 44.0
    static let changeLanguageButtonWidth: CGFloat = 44.0
  }
  
  // MARK: - Public variables
  
  var shouldPresentLoginScreen: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = NSLocalizedString("App Permissions", comment: "")
    permission = Permission(viewController: self)
    setupTableView()
    
    self.navigationItem.rightBarButtonItems = [infoButtonBarItem(), shareAppButtonBarItem()]
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(accessebilityFocusObserver(_:)),
                                           name: UIAccessibility.elementFocusedNotification,
                                           object: nil)
    
    if shouldPresentLoginScreen {
      let loginVC = LoginViewController()
      self.present(loginVC, animated: true, completion: nil)
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: UIAccessibility.elementFocusedNotification,
                                              object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    submitButton.setTitle(Localization.contributeToASaferIndia, for: .normal)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    AnalyticsManager.setScreenName(name: ScreenName.permissionScreen,
                                   className: NSStringFromClass(type(of: self)))
  }
  
  fileprivate func setupTableView() {
    registerTableViewCells()
    tableView.dataSource = self
  }
  
  fileprivate func registerTableViewCells() {
    tableView.register(UINib(nibName: "PermissionScreenPermissionTableViewCell", bundle: nil), forCellReuseIdentifier: "PermissionScreenPermissionTableViewCell")
    tableView.register(UINib(nibName: "PermissionScreenTnCCellTableViewCell", bundle: nil), forCellReuseIdentifier: "PermissionScreenTnCCellTableViewCell")
    tableView.register(UINib(nibName: "PermissionScreenEncryptionTableViewCell", bundle: nil), forCellReuseIdentifier: "PermissionScreenEncryptionTableViewCell")
  }
  
  @IBAction func startSharingButtonTapped(_ sender: UIButton) {
    
    if UserDefaults.standard.bool(forKey: "askedForBluetooth") == false {
      permission.requestBluetooth()
    }
    
    let bluetoothStatus = permission.statusBluetooth()
    let locationStatus = permission.statusLocation()
    
    let status = (bluetoothStatus, locationStatus)
    switch status {
    case (_, .authorized):
      let loginVC = LoginViewController()
      self.present(loginVC, animated: true, completion: nil)
      
    default:
      permission.requestLocation()
    }
  }
  
  
  @IBAction func shareAppButtonTapped(_ sender: UIBarButtonItem) {
    permission.shareApp()
    let params = ["screenName" : "PermissionScreenViewController"]
    AnalyticsManager.logEvent(name: Events.shareClicked, parameters: params)
  }
  
  @IBAction func changeLanguageButtonTapped(_ sender: UIBarButtonItem) {
    let storyboard = UIStoryboard(name: Constants.Storyboard.languageSelection, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.languageSelection)
    (controller as? LanguageSelectionViewController)?.delegate = self
    self.present(controller, animated: true, completion: nil)
  }
  
  fileprivate func shareAppButtonBarItem() -> UIBarButtonItem {
    let button = UIBarButtonItem(image: #imageLiteral(resourceName: "share_app"),
                                 style: .plain,
                                 target: self,
                                 action: #selector(shareAppButtonTapped))
    button.accessibilityLabel = AccessibilityLabel.shareApp
    button.width = Defaults.shareAppButtonWidth
    return button
  }
  
  fileprivate func infoButtonBarItem() -> UIBarButtonItem {
    let button = UIBarButtonItem(image: #imageLiteral(resourceName: "languageChangeCopy3"),
                                 style: .plain,
                                 target: self,
                                 action: #selector(changeLanguageButtonTapped))
    button.accessibilityLabel = AccessibilityLabel.languageChange
    button.width = Defaults.changeLanguageButtonWidth
    return button
  }
  
  @objc private func accessebilityFocusObserver(_ notification: Notification) {
    debugPrint(notification.userInfo ?? [:])
    if let view = notification.userInfo?["UIAccessibilityFocusedElementKey"] as? UIAccessibilityElement,
      view.accessibilityLabel == Localization.permissionScreenTnC {
      printForDebug(string: "Focus on PermissionScreenTnCCellTableViewCell")
    }
  }
}

extension PermissionScreenViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 1:
        return 3
    default:
        return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PermissionScreenEncryptionTableViewCell")! as! PermissionScreenEncryptionTableViewCell
      cell.selectionStyle = .none
      cell.configure()
      return cell
    }
    else if indexPath.section == 2 {
         let cell = tableView.dequeueReusableCell(withIdentifier: "PermissionScreenTnCCellTableViewCell")! as! PermissionScreenTnCCellTableViewCell
        cell.selectionStyle = .none
        cell.addHyperLink()
        cell.delegate = self
        return cell
    }
    else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PermissionScreenPermissionTableViewCell")! as! PermissionScreenPermissionTableViewCell
      cell.configure(title: titles[indexPath.row],
                     subtitle: subtitles[indexPath.row],
                     accessibilityTitle: accessibilityTitles[indexPath.row],
                     accessibilitySubtitle: accessibilitySubtitles[indexPath.row])
      cell.selectionStyle = .none
      return cell
      
    }
  }
}

extension PermissionScreenViewController: LanguageSelectionDelegate {
  
  func selectedLangauge(lang code: String) {
    titles = [Localization.deviceLocation, Localization.bluetooth, Localization.dataSharingWithMoh]
    subtitles = [Localization.setsYourLocation, Localization.monitorsYourDevice, Localization.dataWillBeSentOnlyToMoi]
    submitButton.setTitle(Localization.contributeToASaferIndia, for: .normal)
    tableView.reloadData()
  }
}

extension PermissionScreenViewController: PermissionScreenTnCCellTableViewCellDelegate {
 
  func permissionScreenTnCCellTableViewCell(_ cell: PermissionScreenTnCCellTableViewCell,
                                            urlTapped url: URL) {
    let vc = TncViewController(url: url)
    vc.modalPresentationStyle = .fullScreen
    self.present(vc, animated: true, completion: nil)
  }
}
