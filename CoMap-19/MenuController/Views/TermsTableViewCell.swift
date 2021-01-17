//
//  TermsTableViewCell.swift
//  CoMap-19
//

//
//

import UIKit

class TermsTableViewCell: UITableViewCell {

  // MARK: - IBOutlets
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.textColor = UIColor(red: 0.0, green: 140.0/255.0, blue: 1.0, alpha: 1.0)
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14.0)
    }
  }
  
  // MARK: - Pubic methods
  
  func configure(title: String) {
    titleLabel.text = title
  }
}
