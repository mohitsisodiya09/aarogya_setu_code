//
//  DeleteAccountViewController.swift
//  CoMap-19
//

//

import UIKit
import SVProgressHUD
import WebKit

class DeleteAccountViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var deleteAccountButton: UIButton! {
    didSet {
      deleteAccountButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
      deleteAccountButton.setTitle(Localization.deleteAccount, for: .normal)
      deleteAccountButton.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.4823529412, blue: 0.5215686275, alpha: 0.3)
      deleteAccountButton.isEnabled = false
    }
  }
  @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
  
  // MARK: - Private members
  fileprivate enum Sections {
    case webView
    case confirmNumber
  }
  
  fileprivate enum Rows {
    case webView
  }
  
  private var confirmNumberHeader: ConfirmNumberHeader?
  private var sectionLayout: [Sections] = []
  private var sectionRowMapping: [Sections: [Rows]] = [:]
  private var webViewHeight: CGFloat = UIScreen.main.bounds.height * 0.40

  // MARK: - Lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = NSLocalizedString("Delete My Account", comment: "")
    navigationController?.setNavigationBarHidden(false, animated: true)
    addBackButton()
    setupTableView()
    addKeyboardObservers()
  }
  
  deinit {
    removeKeyboardObservers()
  }
  
  // MARK: - Private methods
  
  private func addBackButton() {
    self.navigationItem.hidesBackButton = true
    
    let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_icon").withRenderingMode(.alwaysOriginal),
                                     style: .plain,
                                     target: self,
                                     action: #selector(backButtonAction(_:)))
    backButton.accessibilityLabel = AccessibilityLabel.back
    
    self.navigationItem.leftBarButtonItem = backButton
  }
  
  fileprivate func setupTableView() {
    tableView.register(UINib(nibName: "DeleteAccountHeader", bundle: nil),
                       forCellReuseIdentifier: "DeleteAccountHeader")
    tableView.register(UINib(nibName: "DeleteAccountWebViewTableViewCell", bundle: nil),
                       forCellReuseIdentifier: "DeleteAccountWebViewTableViewCell")
    
    tableView.estimatedRowHeight = UITableView.automaticDimension
    tableView.estimatedSectionHeaderHeight = 44.0
    tableView.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude
    
    tableView.rowHeight = UITableView.automaticDimension
    
    configureSections()
    configureRows()
    
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  fileprivate func configureSections() {
    sectionLayout = [.webView, .confirmNumber]
  }
  
  fileprivate func configureRows() {
    for section in sectionLayout {
      if section == .webView {
        sectionRowMapping[.webView] = Array<Rows>(repeating: .webView, count: 1)
      }
    }
  }
  
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

      tableViewBottomConstraint.constant = keyboardHeight

      view.layoutIfNeeded()
      UIView.animate(withDuration: animationDuration, animations: {
        self.view.layoutIfNeeded()
      })
    }
  }

  @objc fileprivate func keyboardWillHide(_ sender: NSNotification) {
    
    if let animationDuration = sender.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {

      UIView.animate(withDuration: animationDuration, animations: {
        self.tableViewBottomConstraint.constant = 0
      })
    }
  }
  
  // MARK: - Button Actions
  @IBAction func backButtonAction(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @IBAction func deleteButtonAction(_ sender: UIButton) {
    SVProgressHUD.show()
    APIClient.sharedInstance.deleteAccount { (responseObject, _, error) in
      SVProgressHUD.dismiss()
      
      if let error = error {
        ToastView.showToastMessage(error.localizedDescription)
        return
      }
      
      KeychainHelper.removeName()
      KeychainHelper.removeAwsToken()
      KeychainHelper.removeQrMetaData()
      KeychainHelper.removeRefreshToken()
      KeychainHelper.removeMobileNumber()
      AWSAuthentication.sharedInstance.signOutUserIfLoggedIn()
      
      APIClient.sharedInstance.refreshToken = nil
      APIClient.sharedInstance.authorizationToken = nil
      
      UserDefaults.standard.set(false, forKey: "isUserAuthenticated")
      UserDefaults.standard.removeObject(forKey: Constants.UserDefault.isFirstLaunch)
      
      let appDelegate = UIApplication.shared.delegate as? AppDelegate
      appDelegate?.window?.rootViewController = nil
      appDelegate?.window?.rootViewController = ContainerController()
    }
    
  }
  
  
}

// MARK: - UITableViewDataSource
extension DeleteAccountViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sectionLayout.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sectionRowMapping[sectionLayout[section]]?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteAccountWebViewTableViewCell",
                                                   for: indexPath) as? DeleteAccountWebViewTableViewCell else {
      return UITableViewCell()
    }
    cell.loadUrl(Constants.WebUrl.deleteUrl)
    return cell
  }
  
}

// MARK: - UITableViewDelegate
extension DeleteAccountViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let sectionType = sectionLayout[indexPath.section]
    switch sectionType {
    case .webView:
      return webViewHeight
    default:
      return UITableView.automaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let sectionType = sectionLayout[section]
    switch sectionType {
    case .webView:
      return nil
      
    case .confirmNumber:
      if self.confirmNumberHeader == nil {
        self.confirmNumberHeader = ConfirmNumberHeader()
        self.confirmNumberHeader?.delegate = self
      }
      return self.confirmNumberHeader
    }
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let sectionType = sectionLayout[section]
    switch sectionType {
    case .webView:
      return CGFloat.leastNormalMagnitude
    case .confirmNumber:
      return 220.0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
  
}

// MARK: - ConfirmNumberHeaderDelegate
extension DeleteAccountViewController: ConfirmNumberHeaderDelegate {
  
  func confirmNumberHeader(valueChanged mobileNumber: String, countryCode: String) {
    let isMobileNumberValid: Bool = (mobileNumber.isNumber() == true && mobileNumber.count == 10)
    
    let isMobileNumberEqualToSavedNumber: Bool = KeychainHelper.getMobileNumber() == String(format: "%@%@", countryCode,mobileNumber)
    
    deleteAccountButton.backgroundColor = (isMobileNumberValid && isMobileNumberEqualToSavedNumber) ? #colorLiteral(red: 0.9607843137, green: 0.4823529412, blue: 0.5215686275, alpha: 1) : #colorLiteral(red: 0.9607843137, green: 0.4823529412, blue: 0.5215686275, alpha: 0.3)
    deleteAccountButton.isEnabled = isMobileNumberValid && isMobileNumberEqualToSavedNumber
  }
  
}
