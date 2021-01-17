//
//  UserStatusPreferenceTableViewCell.swift
//  CoMap-19
//

//

import UIKit

final class UserStatusPreferenceTableViewCell: UITableViewCell {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
      subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
    }
  }
  
  @IBOutlet weak var appIconImageView: UIImageView! {
    didSet {
      appIconImageView.layer.cornerRadius = 8.0
    }
  }
  
  @IBOutlet weak var seperatorView: UIView!
  
  // MARK: - Private methods
  
  fileprivate func setSubtitleLabel(_ preference: UserStatusPreference) {
    switch preference.type {
    case .alwaysAsk:
      subtitleLabel.text = Localization.askForApproval
      
    case .alwaysApprove:
      subtitleLabel.text = Localization.alwaysApprove.capitalized
      
    case .block:
      subtitleLabel.text = Localization.blocked
      
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
  
   // MARK: - Public methods
  
  func configure(preference: UserStatusPreference, shouldShowSeperator: Bool) {
    if let name = preference.name {
      titleLabel.text = name
      titleLabel.isHidden = false
    }
    else {
      titleLabel.isHidden = true
    }
    
    setAppImage(urlString: preference.imageUrl)
   
    if let firstLetter = preference.name?.first, preference.imageUrl == nil || preference.imageUrl?.isEmpty == true  {
      appIconImageView.image = String(firstLetter).image()
      appIconImageView.isHidden = false
    }
    setSubtitleLabel(preference)
    seperatorView.isHidden = !shouldShowSeperator
  }
}
