//
//  PendingRequestTableViewCell.swift
//  CoMap-19
//

//

import UIKit

protocol PendingRequestTableViewCellDelegate: AnyObject {
  func pendingRequestTableViewCell(_ cell: PendingRequestTableViewCell,
                                   viewAllRequestButtonTapped sender: UIButton)
}

final class PendingRequestTableViewCell: UITableViewCell {

  // MARK: - IBOutlet
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 12.0)
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
      subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
    }
  }
    
  @IBOutlet weak var requestStatusLabel: UILabel! {
    didSet {
      requestStatusLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      requestStatusLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12.0)
    }
  }
  
  @IBOutlet weak var viewRequestButton: UIButton! {
    didSet {
      viewRequestButton.setTitleColor(#colorLiteral(red: 0, green: 0.5647058824, blue: 1, alpha: 1), for: .normal)
      viewRequestButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
      viewRequestButton.setTitle(Localization.viewRequest, for: .normal)
    }
  }
  
  @IBOutlet weak var appIconImageView: UIImageView! {
    didSet {
      appIconImageView.layer.cornerRadius = 16.0
    }
  }
  
  @IBOutlet weak var requestStatusImageView: UIImageView!
  
  @IBOutlet weak var requestStatusContainerView: UIView!
  
  @IBOutlet weak var containerView: UIView!
  
  // MARK: - Public variables
  
  weak var delegate: PendingRequestTableViewCellDelegate?
  
  // MARK: - Public method
  
  func configure(request: PendingRequest) {
    setAppImage(urlString: request.imageUrl)
    setSubtitleLabel(request.createdOn)
    
    if let firstLetter = request.name?.first,
      (request.imageUrl?.isEmpty == true || request.imageUrl == nil) {
    
      appIconImageView.image = String(firstLetter).image()
      appIconImageView.isHidden = false
    }
    
    requestStatusContainerView.isHidden = false
    viewRequestButton.isHidden = true
    var message =  String.localizedStringWithFormat(Localization.pendingRequest, request.name ?? "")
    
    if let startDate = request.startDate?.toDate(format: "yyyy-MM-dd HH:mm"), let endDate = request.endDate?.toDate(format: "yyyy-MM-dd HH:mm") {
     
      let startDateString = startDate.toString(format: "dd MMM, YY (h:mm a)")
      let endDateString = endDate.toString(format: "dd MMM, YY (h:mm a)")
      message.append(contentsOf: String(format: " from %@ to %@", startDateString, endDateString))
    }
  
    if let reason = request.reason, reason.isEmpty == false {
      message.append(contentsOf: String(format: " for %@", reason))
    }
    
    titleLabel.text = message
    
    containerView.backgroundColor = .white
    
    switch request.requestStatus {
    case .pending:
      containerView.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.9568627451, blue: 1, alpha: 1)
      requestStatusContainerView.isHidden = true
      viewRequestButton.isHidden = false
      break
      
    case .approved:
      requestStatusImageView.image = #imageLiteral(resourceName: "request_approved")
      requestStatusLabel.text = Localization.approved
      break
      
    case .alwaysApproved:
      requestStatusImageView.image = #imageLiteral(resourceName: "request_always_approved")
      requestStatusLabel.text = Localization.alwaysApproved
      break
      
    case .rejected, .raNotInitiated, .raSpam, .raBlock, .raOthers:
      requestStatusImageView.image = #imageLiteral(resourceName: "request_reject")
      requestStatusLabel.text = Localization.rejected
      break
      
    case .autoApproved:
      requestStatusImageView.image = #imageLiteral(resourceName: "request_always_approved")
      requestStatusLabel.text = Localization.autoApproved
      break
      
    case .autoRejected:
      requestStatusImageView.image = #imageLiteral(resourceName: "request_reject")
      requestStatusLabel.text = Localization.autoRejected
      break
      
    default:
      break
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
  
  fileprivate func setSubtitleLabel(_ subtitle: String?) {
    if let subtitle = subtitle, let date = subtitle.toDate() {
      let timeDiffInMins = Date().minutes(from: date)
      
      if timeDiffInMins < 60 && timeDiffInMins > 0  {
        subtitleLabel.text = String(format: Localization.minutesAgo, timeDiffInMins)
      }
      else if Calendar.current.isDateInToday(date) {
        subtitleLabel.text = date.toString(format: "'Today at' h:mm a")
      }
      else {
        subtitleLabel.text = date.toString(format: "MMM dd 'at' h:mm a")
      }
    }
  }
  
  // MARK: - IBActions
  
  @IBAction func viewRequestButtonTapped(_ sender: UIButton) {
    delegate?.pendingRequestTableViewCell(self, viewAllRequestButtonTapped: sender)
  }
}
