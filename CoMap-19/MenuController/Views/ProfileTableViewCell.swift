//
//  ProfileTableViewCell.swift
//  CoMap-19
//

//
//

import UIKit

final class ProfileTableViewCell: UITableViewCell {

  // MARK: - IBOutlets
  
  @IBOutlet weak var nameLabel: UILabel! {
    didSet {
      nameLabel.textColor = UIColor.black
      nameLabel.font = UIFont(name: "AvenirNext-Bold", size: 14.0)
    }
  }
  
  @IBOutlet weak var mobileNumberLabel: UILabel! {
    didSet {
      mobileNumberLabel.textColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
      mobileNumberLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
    }
  }
  
  // MARK: - Configure methods
  
  func configure(name: String?, mobileNumber: String?) {
 
    if let name = name {
      nameLabel.text = name
      nameLabel.isHidden = false
    }
    else {
      nameLabel.isHidden = true
    }
    
    if let mobileNumber = mobileNumber {
      mobileNumberLabel.text = mobileNumber
      mobileNumberLabel.isHidden = false
    }
    else {
      mobileNumberLabel.isHidden = true
    }
  }
}
