//
//  StatusRequestCollectionViewCell.swift
//  CoMap-19
//

//

import UIKit

protocol StatusRequestCollectionViewCellDelegate: AnyObject {
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       crossButtonTapped sender: UIButton)
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       approveButtonTapped sender: UIButton)
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       rejectButtonTapped sender: UIButton)
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       alwaysApproveButtonTapped sender: UIButton)
  func statusRequestCollectionViewCell(_ cell: StatusRequestCollectionViewCell,
                                       reportAbuseButtonTapped sender: UIButton)
}

final class StatusRequestCollectionViewCell: UICollectionViewCell {
  
  // MARK: - Private variables
  
  fileprivate struct Defaults {
    static let cornerRadius: CGFloat = 25.0
    static let borderWidth: CGFloat = 1.0
    static let containerViewCornerRadius: CGFloat = 8.0
  }

  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 1, alpha: 1)
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18.0)
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      subtitleLabel.font = UIFont(name: "AvenirNext-Bold", size: 12.0)
    }
  }
  
  @IBOutlet weak var statusValidationDurationLabel: UILabel! {
    didSet {
      statusValidationDurationLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.6, blue: 0.5843137255, alpha: 1)
      statusValidationDurationLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
    }
  }
  
  @IBOutlet weak var appIconImageView: UIImageView! {
    didSet {
      appIconImageView.layer.cornerRadius = 8.0
    }
  }
  
  @IBOutlet weak var requestStatusImageView: UIImageView!
  
  @IBOutlet weak var approveButton: UIButton! {
    didSet {
      approveButton.setTitle(Localization.approve, for: .normal)
      approveButton.layer.cornerRadius = Defaults.cornerRadius
      approveButton.layer.borderColor = UIColor.white.cgColor
      approveButton.backgroundColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
      approveButton.setTitleColor(UIColor.white, for: .normal)
      approveButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    }
  }
  
  @IBOutlet weak var alwaysApproveButton: UIButton! {
    didSet {
      alwaysApproveButton.setTitle(Localization.alwaysApprove, for: .normal)
      alwaysApproveButton.layer.cornerRadius = Defaults.cornerRadius
      alwaysApproveButton.layer.borderWidth = Defaults.borderWidth
      alwaysApproveButton.layer.borderColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
      alwaysApproveButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
      alwaysApproveButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    }
  }
  
  @IBOutlet weak var rejectButton: UIButton! {
    didSet {
      rejectButton.setTitle(Localization.reject, for: .normal)
      rejectButton.layer.cornerRadius = Defaults.cornerRadius
      rejectButton.layer.borderWidth = Defaults.borderWidth
      rejectButton.layer.borderColor = #colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1)
      rejectButton.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.2901960784, blue: 0.2901960784, alpha: 1), for: .normal)
      rejectButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
    }
  }
  
  @IBOutlet weak var reportAbuseButton: UIButton! {
    didSet {
      reportAbuseButton.setTitle(Localization.reportAbuse, for: .normal)
      reportAbuseButton.setTitleColor(#colorLiteral(red: 0, green: 0.5490196078, blue: 1, alpha: 1), for: .normal)
      reportAbuseButton.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
      reportAbuseButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
    }
  }
  
  @IBOutlet weak var statusValidationContainerView: UIView! {
    didSet {
      statusValidationContainerView.layer.cornerRadius = 4.0
      statusValidationContainerView.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.cornerRadius = Defaults.containerViewCornerRadius
    }
  }
  
  @IBOutlet weak var reportAbuseButtonHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Public variables
  
  weak var delegate: StatusRequestCollectionViewCellDelegate?
  
  // MARK: - IBActions
  
  @IBAction func crossButtonTapped(_ sender: UIButton) {
    delegate?.statusRequestCollectionViewCell(self, crossButtonTapped: sender)
  }
  
  @IBAction func approveButtonTapped(_ sender: UIButton) {
    delegate?.statusRequestCollectionViewCell(self, approveButtonTapped: sender)
  }
  
  @IBAction func rejectButtonTapped(_ sender: UIButton) {
    delegate?.statusRequestCollectionViewCell(self, rejectButtonTapped: sender)
  }
  
  @IBAction func alwaysApproveButtonTapped(_ sender: UIButton) {
    delegate?.statusRequestCollectionViewCell(self, alwaysApproveButtonTapped: sender)
  }
  
  @IBAction func reportAbuseButtonTapped(_ sender: UIButton) {
    delegate?.statusRequestCollectionViewCell(self, reportAbuseButtonTapped: sender)
  }
  
  // MARK: - Public methods
  
  func configure(statusRequest: StatusRequestResponse, isSuccessfull: (Bool, RequestStatusType)) {
    setAppName(statusRequest.appName)
    setRequestReason(statusRequest.reason)
    setAppImage(urlString: statusRequest.imageUrl)
    
    if let firstLetter = statusRequest.appName?.first,
       (statusRequest.imageUrl?.isEmpty == true || statusRequest.imageUrl == nil) {
     
      appIconImageView.image = String(firstLetter).image()
      appIconImageView.isHidden = false
    }
    requestStatusImageView.isHidden = true
    
    if let startDate = statusRequest.startDate?.toDate(format: "yyyy-MM-dd HH:mm"), let endDate = statusRequest.endDate?.toDate(format: "yyyy-MM-dd HH:mm") {
      
      let startDateString = startDate.toString(format: "dd MMM, YY (h:mm a)")
      let endDateString = endDate.toString(format: "dd MMM, YY (h:mm a)")
      
      statusValidationDurationLabel.text = String(format: "This request is from %@ to %@", startDateString, endDateString)
      statusValidationContainerView.isHidden = false
    }
    else {
      statusValidationContainerView.isHidden = true
    }
  
    if isSuccessfull.0 == true {
      setupStatusRequestSuccessResponse(type: isSuccessfull.1, appName: statusRequest.appName)
      reportAbuseButtonHeightConstraint.constant = 0
    }
    else {
      reportAbuseButtonHeightConstraint.constant = 50
      alwaysApproveButton.isHidden = false
      rejectButton.isHidden = false
      approveButton.isHidden = false
      reportAbuseButton.isHidden = false
      approveButton.setTitle(Localization.approve, for: .normal)
      requestStatusImageView.isHidden = true
      statusValidationDurationLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.6, blue: 0.5843137255, alpha: 1)
      statusValidationDurationLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
      statusValidationContainerView.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    }
  }
  
  // MARK: - Private methods
    
  fileprivate func setAppName(_ name: String?) {
    titleLabel.text = name
    titleLabel.isHidden = name == nil
  }
  
  fileprivate func setRequestReason(_ reason: String?) {
    if let reason = reason {
      subtitleLabel.isHidden = false
      
      let reasonString = NSMutableAttributedString(string: reason,
                                                   attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)])
      
      let whyString = String.localizedStringWithFormat(" %@ ", Localization.why)
      let attributedString = NSMutableAttributedString(string: whyString,
                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                    NSAttributedString.Key.backgroundColor: #colorLiteral(red: 0.1411764706, green: 0.6, blue: 0.5843137255, alpha: 1)])
      let spaceString = NSAttributedString(string: " ")
      attributedString.append(spaceString)
      
      attributedString.append(reasonString)
      
      
      subtitleLabel.attributedText = attributedString
    }
    else {
      subtitleLabel.isHidden = true
    }
  }
  
  fileprivate func setAppImage(urlString: String?) {
    if let urlString = urlString, let url = URL(string: urlString) {
      do {
        let imageData = try Data(contentsOf: url)
        appIconImageView.image = UIImage(data: imageData)
        appIconImageView.isHidden = false
      }
      catch _ {
        appIconImageView.isHidden = true
      }
    }
    else {
      appIconImageView.isHidden = true
    }
  }
  
  fileprivate func setupStatusRequestSuccessResponse(type: RequestStatusType, appName: String?) {
    
    alwaysApproveButton.isHidden = true
    rejectButton.isHidden = true
    
    approveButton.setTitle(Localization.ok, for: .normal)
    subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 14.0)
    
    requestStatusImageView.isHidden = false
    
    statusValidationContainerView.backgroundColor = UIColor.white
    statusValidationDurationLabel.textColor = UIColor.black
    
    reportAbuseButton.isHidden = true
    
    let appName = appName ?? ""
    
    switch type {
    case .approve:
      titleLabel.text = Localization.requestApproved
      subtitleLabel.text = String.localizedStringWithFormat(Localization.requestApprovedMessage, appName)
      requestStatusImageView.image = #imageLiteral(resourceName: "request_approved")
      
    case .reject:
      titleLabel.text = Localization.requestRejected
      subtitleLabel.text = String.localizedStringWithFormat(Localization.requestRejectedMessage, appName)
      requestStatusImageView.image = #imageLiteral(resourceName: "request_reject")
      
    case .alwaysApprove:
      titleLabel.text = Localization.requestApproved
      subtitleLabel.text = String.localizedStringWithFormat(Localization.requestAlwaysApprovedMessage, appName)
      requestStatusImageView.image = #imageLiteral(resourceName: "request_always_approved")
    }
  }
}
