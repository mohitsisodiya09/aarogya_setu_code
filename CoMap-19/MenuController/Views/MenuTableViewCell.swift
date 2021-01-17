//
//  MenuTableViewCell.swift
//  CoMap-19
//

//
//

import UIKit

final class MenuTableViewCell: UITableViewCell {

  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
      titleLabel.textColor = UIColor.black
    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
      subtitleLabel.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    }
  }
  
  @IBOutlet weak var countLabel: UILabel! {
    didSet {
      countLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 12.0)
      countLabel.textColor = UIColor.white
           countContainerView.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.3882352941, blue: 0.4470588235, alpha: 1)
    }
  }
  
  @IBOutlet weak var countContainerView: UIView! {
    didSet {
      countContainerView.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.3882352941, blue: 0.4470588235, alpha: 1)
      countContainerView.layer.cornerRadius = 10.0
    }
  }
  
  @IBOutlet weak var iconImageView: UIImageView!
  
  // MARK: - Public methods
  
  func configure(title: String, subtitle: String?, iconName: String, count: String? = nil) {
    titleLabel.text = title
    
    if let subtitle = subtitle {
      subtitleLabel.text = subtitle
      subtitleLabel.isHidden = false
    }
    else {
      subtitleLabel.isHidden = true
    }
    
    countLabel.text = count
    countContainerView.isHidden = count == nil
    
    iconImageView.image = UIImage(named: iconName)
  }
}
