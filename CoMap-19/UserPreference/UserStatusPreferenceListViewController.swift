//
//  UserStatusPreferenceListViewController.swift
//  CoMap-19
//

//

import UIKit
import SVProgressHUD

fileprivate enum PreferenceType {
  case user
  case app
}

final class UserStatusPreferenceListViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var emptyStateView: UIView!
  
  @IBOutlet weak var segmentControl: UISegmentedControl! {
    didSet {
      segmentControl.setTitle(Localization.apps, forSegmentAt: 0)
      segmentControl.setTitle(Localization.users, forSegmentAt: 1)
    }
  }
  @IBOutlet weak var emptyStateTitleLabel: UILabel! {
    didSet {
      emptyStateTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
      emptyStateTitleLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
      emptyStateTitleLabel.text = Localization.userPreferenceNoRecord
    }
  }
  
  // MARK: - Private variables
  
  fileprivate var statusPreferences: [UserStatusPreference]? {
    didSet {
      if preferenceType == .app {
        userSelectedPreference = statusPreferences?.filter({$0.isUser == false})
      }
      else if preferenceType == .user {
        userSelectedPreference = statusPreferences?.filter({$0.isUser == true})
      }
    }
  }
  
  fileprivate var userSelectedPreference: [UserStatusPreference]?
  
  fileprivate var preferenceType: PreferenceType = .app {
    didSet {
      
      if preferenceType == .app {
        userSelectedPreference = statusPreferences?.filter({$0.isUser == false})
      }
      else if preferenceType == .user {
        userSelectedPreference = statusPreferences?.filter({$0.isUser == true})
      }
      
      if userSelectedPreference?.isEmpty == false {
        hideEmptyStateView()
        self.tableView.isHidden = false
        tableView.reloadData()
      }
      else {
        showEmptyStateView()
        self.tableView.isHidden = true
      }
    }
  }

  // MARK: - View Life cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    prepareTableView()
    getUserStatusPreferences()
    self.title = Localization.approvalPreferences
    addRefreshMsmeStatusNavBarItem()
  }
  
  // MARK: - Private methods
  
  fileprivate func addRefreshMsmeStatusNavBarItem() {
    self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "refresh"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(getUserStatusPreferences))
  }
  
  fileprivate func prepareTableView() {
    registerTableViewCells()
    
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none
    
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  fileprivate func registerTableViewCells() {
    tableView.register(UINib(nibName: String(describing: UserStatusPreferenceTableViewCell.self), bundle: nil),
                       forCellReuseIdentifier: String(describing: UserStatusPreferenceTableViewCell.self))
  }
  
  @objc fileprivate func getUserStatusPreferences() {
    
    SVProgressHUD.show()
    
    APIClient.sharedInstance.getUserStatusPreferences { [weak self] (responseObject, _, error) in
    
      SVProgressHUD.dismiss()
      
      guard let self = self else {
        return
      }
      
      if let error = error  {
        print(error)
        ToastView.showToastMessage(error.localizedDescription)
      }
      else if let responseObject = responseObject as? [String: Any] {
        if let request = responseObject[Constants.ApiKeys.data] as? [Any] {
          do {
            let data = try JSONSerialization.data(withJSONObject: request, options: [])
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let statusPreferences = try decoder.decode([UserStatusPreference].self, from: data)
            self.statusPreferences = statusPreferences
            
            if statusPreferences.isEmpty == true {
              self.showEmptyStateView()
            }
            else {
              self.hideEmptyStateView()
              self.tableView.reloadData()
            }
            
          }
          catch let error {
            ToastView.showToastMessage(error.localizedDescription)
          }
        }
        else {
          self.tableView.isHidden = true
          self.showEmptyStateView()
          self.statusPreferences = nil
        }
      }
      else {
        self.tableView.isHidden = true
        self.showEmptyStateView()
      }
    }
  }
  
  fileprivate func showEmptyStateView() {
    emptyStateView.isHidden = false
  }
  
  fileprivate func hideEmptyStateView() {
    emptyStateView.isHidden = true
  }
  
  // MARK: - IBAction
  
  @IBAction func actionCalled(_ sender: UISegmentedControl) {
 
    if segmentControl.selectedSegmentIndex == 0 {
      preferenceType = .app
    }
    else if segmentControl.selectedSegmentIndex == 1 {
      preferenceType = .user
    }
  }
}

// MARK: - UITableViewDelegate methods

extension UserStatusPreferenceListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if let statusPreference = userSelectedPreference?[indexPath.row] {
      let userStatusVC = UserStatusPreferenceViewController(statusPreference: statusPreference)
      userStatusVC.delegate = self
      self.present(userStatusVC, animated: true, completion: nil)
    }
  }
}

// MARK: - UITableViewDataSource methods

extension UserStatusPreferenceListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userSelectedPreference?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserStatusPreferenceTableViewCell")! as! UserStatusPreferenceTableViewCell
    cell.selectionStyle = .none
   
    if let preference = userSelectedPreference?[indexPath.row] {
      cell.configure(preference: preference, shouldShowSeperator: true)
    }
    
    return cell
  }
}

// MARK: - UserStatusPreferenceViewControllerDelegate methods implementation

extension UserStatusPreferenceListViewController: UserStatusPreferenceViewControllerDelegate {
  func userStatusPreferenceChanged(vc: UserStatusPreferenceViewController) {
    vc.dismiss(animated: true, completion: nil)
    
    getUserStatusPreferences()
  }
}
