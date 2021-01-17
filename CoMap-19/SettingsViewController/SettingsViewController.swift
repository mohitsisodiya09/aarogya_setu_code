//
//  SettingsViewController.swift
//  CoMap-19
//

//

import UIKit

fileprivate enum RowType {
  case deleteAccount
  case status
}

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Private variables
  
  fileprivate var rowLayout = [RowType]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = Localization.settings
    navigationController?.setNavigationBarHidden(false, animated: true)
    addBackButton()
    
    prepareTableView()
  }
  
  // MARK: - Private methods
    
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
    tableView.register(UINib(nibName: String(describing: SettingsTableViewCell.self), bundle: nil),
                       forCellReuseIdentifier: String(describing: SettingsTableViewCell.self))
    tableView.register(UINib(nibName: String(describing: UserStatusPreferenceTableViewCell.self), bundle: nil),
                       forCellReuseIdentifier: String(describing: UserStatusPreferenceTableViewCell.self))
  }
  
  fileprivate func prepareTableViewLayout() {
    prepareRowLayout()
  }

  fileprivate func prepareRowLayout() {
    rowLayout = [.status, .deleteAccount]
  }
  
  fileprivate func getRowType(_ indexPath: IndexPath) -> RowType? {
    return rowLayout[indexPath.row]
  }
  
  fileprivate func addBackButton() {
    self.navigationItem.hidesBackButton = true
    
    let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "back_icon").withRenderingMode(.alwaysOriginal),
                                     style: .plain,
                                     target: self,
                                     action: #selector(backButtonAction(_:)))
    backButton.accessibilityLabel = AccessibilityLabel.back
    
    self.navigationItem.leftBarButtonItem = backButton
  }
  
  // MARK: - Button Actions
  
  @IBAction func backButtonAction(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - UITableViewDelegate methods

extension SettingsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let rowType = getRowType(indexPath) else {
      fatalError("Unknown row type found")
    }
    
    switch rowType {
      
    case .deleteAccount:
      let deleteAccontVC = DeleteAccountViewController()
      self.navigationController?.pushViewController(deleteAccontVC, animated: true)
      
    case .status:
      let statusListVC = UserStatusPreferenceListViewController()
      self.navigationController?.pushViewController(statusListVC, animated: true)

    }
  }
}

// MARK: - UITableViewDataSource methods

extension SettingsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rowLayout.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let rowType = getRowType(indexPath) else {
      fatalError("Unknown row type found")
    }
    
    switch rowType {
    case .deleteAccount:
      let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell")! as! SettingsTableViewCell
      cell.configure(title: Localization.deleteMyAccount,
                     subtitle: Localization.permanentDeleteAccount,
                     iconName: "delete_grey",
                     shouldShowSeperator: true)
      return cell
      
    case .status:
      let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell")! as! SettingsTableViewCell
      
      let subtitle = Localization.externalAppsAccessSetu
      
      cell.configure(title: Localization.approvalForAarogyaSetuStatus,
                     subtitle: subtitle,
                     iconName: "aarogya_setu",
                     shouldShowSeperator: true)
      return cell
    }
  }
}
