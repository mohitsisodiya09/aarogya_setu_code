//
//  StatusCheckViewController.swift
//  CoMap-19
//

//

import UIKit
import SVProgressHUD

final class StatusCheckViewController: UIViewController {
  
  // MARK: - IBOutlet
  
  @IBOutlet weak var addAccountButton: UIButton! {
    didSet {
      addAccountButton.setTitle(Localization.addAccount, for: .normal)
      addAccountButton.layer.cornerRadius = 25.0
      addAccountButton.backgroundColor = #colorLiteral(red: 0.2235294118, green: 0.2196078431, blue: 0.2509803922, alpha: 1)
      addAccountButton.setTitleColor(UIColor.white, for: .normal)
      addAccountButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    }
  }
  
  @IBOutlet weak var emptyStateTitleLabel: UILabel! {
    didSet {
      emptyStateTitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      emptyStateTitleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      emptyStateTitleLabel.text = Localization.youCanKeepACheck
    }
  }
  
  @IBOutlet weak var generateCodeTitleLabel: UILabel! {
    didSet {
      generateCodeTitleLabel.text = Localization.wantOtherToCheckStatus
      generateCodeTitleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      generateCodeTitleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    }
  }
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var emptyStateContainerView: UIView!
 
  @IBOutlet weak var generateCodeContainerView: UIView! {
    didSet {
      generateCodeContainerView.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9607843137, blue: 1, alpha: 1)
      generateCodeContainerView.addShadow(location: .top)
    }
  }
  
  @IBOutlet weak var generateCodeButton: UIButton! {
    didSet {
      generateCodeButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      generateCodeButton.setTitleColor(#colorLiteral(red: 0, green: 0.5490196078, blue: 1, alpha: 1), for: .normal)
      generateCodeButton.setTitle(Localization.generateAndShareCode, for: .normal)
    }
  }
  
  // MARK: - Private variables
  
  fileprivate var statusList: [StatusMsmeRequest]?
  
  // MARK: - Init methods
  
  convenience init() {
    self.init(nibName: "StatusCheckViewController", bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  // MARK: - View Life Cycle methods
  
  override func viewDidLoad() {
    self.title = NSLocalizedString("Status Check", comment: "")
    
    prepareTableView()
    addBackButton()
    getMesmeStatus()
    self.tableView.isHidden = true
    hideEmptyStateView()
  }
  
  // MARK: - Private methods
  
  fileprivate func prepareTableView() {
    registerTableViewCells()
    
    tableView.estimatedRowHeight = 44.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    
    tableView.dataSource = self
  }
  
  fileprivate func registerTableViewCells() {
    tableView.register(UINib(nibName: String(describing: StatusCheckTableViewCell.self),
                             bundle: nil), forCellReuseIdentifier: String(describing: StatusCheckTableViewCell.self))
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
  
  fileprivate func addRightBarButtonButton() {
    self.navigationItem.hidesBackButton = true
    
    let addButton = UIBarButtonItem(title: Localization.add,
                                    style: .plain,
                                    target: self,
                                    action: #selector(addAction(_:)))
    
    self.navigationItem.rightBarButtonItem = addButton
  }
  
  fileprivate func getMesmeStatus() {
  
     SVProgressHUD.show()
       
       APIClient.sharedInstance.getMsmeStatus { [weak self] (responseObject, _ response, error) in
         
         SVProgressHUD.dismiss()
         
         guard let self = self else {
           return
         }
         
         if let responseObject = responseObject as? [String: Any] {
           if let request = responseObject[Constants.ApiKeys.data] as? [Any] {
             do {
              let data = try JSONSerialization.data(withJSONObject: request, options: [])
              let decoder = JSONDecoder()
              let statusList = try decoder.decode([StatusMsmeRequest].self, from: data)
              self.statusList = statusList
              
              if statusList.isEmpty == false {
                self.hideEmptyStateView()
                self.tableView.isHidden = false
                self.tableView.reloadData()
                self.addRightBarButtonButton()
              }
              else {
                self.showEmptyStateView()
              }
             }
             catch let error {
              ToastView.showToastMessage(error.localizedDescription)
            }
           }
           else if let error = responseObject[Constants.ApiKeys.error] as? [String: Any],
            let message = error[Constants.ApiKeys.message] as? String {
            ToastView.showToastMessage(message)
          }
        }
    }
  }
  
  fileprivate func showEmptyStateView() {
    emptyStateContainerView.isHidden = false
  }
  
  fileprivate func hideEmptyStateView() {
    emptyStateContainerView.isHidden = true
  }
  
  fileprivate func addAccount() {
    let addAccountVC = AddStatusCheckAccountViewController()
    addAccountVC.delegate = self
    self.present(addAccountVC, animated: true, completion: nil)
  }
  
  fileprivate func generateCode() {
    let viewController = ShareStatusCodeViewController()
    self.present(viewController, animated: true, completion: nil)
  }
  
  // MARK: - Button Actions
  
  @IBAction func backButtonAction(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func addAction(_ sender: UIButton) {
    addAccount()
  }
  
  @IBAction func generateCodeButtonTapped(_ sender: UIButton) {
    generateCode()
  }
  
  @IBAction func addAccountButtonTapped(_ sender: UIButton) {
    addAccount()
  }
}

// MARK: UIViewControllerTransitioningDelegate Methods Implementation

extension StatusCheckViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInPresentation()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return ViewControllerFadeInDismiss()
  }
  
}

// MARK: - AddStatusCheckAccountViewControllerDelegate methods implementations

extension StatusCheckViewController: AddStatusCheckAccountViewControllerDelegate {
  
  func userAddeddSuccessfull(_ vc: AddStatusCheckAccountViewController) {
    getMesmeStatus()
    vc.dismiss(animated: true, completion: nil)
  }
}

// MARK: - UITableViewDataSource methods implementations

extension StatusCheckViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return statusList?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCheckTableViewCell")! as! StatusCheckTableViewCell
    
    if let msmeRequest = statusList?[indexPath.row] {
      cell.delegate = self
      cell.configure(msmeRequest: msmeRequest)
    }
    
    return cell
  }
}

extension StatusCheckViewController: StatusCheckTableViewCellDelegate {
  
  func statusCheckTableViewCell(_ cell: StatusCheckTableViewCell, deleteButtonTapped sender: UIButton) {
    
    let otherAlert = UIAlertController(title: nil,
                                       message: nil,
                                       preferredStyle: .actionSheet)
    
    let upgrade = UIAlertAction(title: "Remove", style: .default) { [weak self] (action) in
      
      guard let self = self else {
        return
      }
      
      if let indexPath = self.tableView.indexPath(for: cell), let did = self.statusList?[indexPath.row].did {
        
        let params = [Constants.ApiKeys.did : did]
        
        SVProgressHUD.show()
        
        APIClient.sharedInstance.removeGrantMsmeRequest(params: params) {  (responseObject, _ response, error) in
          
          SVProgressHUD.dismiss()
          
          if let error = error {
            ToastView.showToastMessage(error.description)
          }
          else {
            self.getMesmeStatus()
          }
        }
      }
    }
    
    otherAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
      (alertAction: UIAlertAction!) in
      otherAlert.dismiss(animated: true, completion: nil)
    }))
    
    otherAlert.addAction(upgrade)
    
    self.present(otherAlert, animated: true, completion: nil)
  }
}
