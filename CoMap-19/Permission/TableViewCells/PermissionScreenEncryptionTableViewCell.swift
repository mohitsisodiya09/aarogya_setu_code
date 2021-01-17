//
//  PermissionScreenEncryptionTableViewCell.swift
//  CoMap-19
//
//
//

import UIKit

class PermissionScreenEncryptionTableViewCell: UITableViewCell {
  
  @IBOutlet weak var iconImageView: UIImageView!
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)
      titleLabel.textColor = UIColor.white
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
      subtitleLabel.textColor = UIColor.white
    }
  }
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.backgroundColor = UIColor(red: 61/255, green: 129/255, blue: 228/255, alpha: 1.0)
    }
  }
  func configure() {
    titleLabel.text = Localization.permissionsTitle
    titleLabel.accessibilityLabel = AccessibilityLabel.permissionsTitle
    subtitleLabel.text = Localization.permissionsDetail
    subtitleLabel.accessibilityLabel = AccessibilityLabel.permissionsDetail
  }
}
