//
//  SettingsTableViewCell.swift
//  CoMap-19
//

//

import UIKit

class SettingsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
      titleLabel.textColor = UIColor.black
    }
  }
  @IBOutlet weak var subTitleLabel: UILabel! {
    didSet {
      subTitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
      subTitleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    }
  }
  
  @IBOutlet weak var iconImageView: UIImageView!
  
  @IBOutlet weak var seperatorView: UIView!

  func configure(title: String,
                 subtitle: String?,
                 iconName: String,
                 shouldShowSeperator: Bool) {
   
    titleLabel.text = title
    
    if let subtitle = subtitle {
      subTitleLabel.text = subtitle
      subTitleLabel.isHidden = false
    }
    else {
      subTitleLabel.isHidden = true
    }
    
    iconImageView.image = UIImage(named: iconName)
    seperatorView.isHidden = !shouldShowSeperator
  }
}
