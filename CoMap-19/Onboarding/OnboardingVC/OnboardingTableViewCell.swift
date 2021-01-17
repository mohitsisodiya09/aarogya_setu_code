//
//  OnboardingTableViewCell.swift
//  COVID-19
//

//

import UIKit

class OnboardingTableViewCell: UITableViewCell {
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  static let reuseIdentifier: String = "OnboardingTableViewCell"
}
