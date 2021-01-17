//
//  StatusCheckTableViewCell.swift
//  CoMap-19
//

//

import UIKit

protocol StatusCheckTableViewCellDelegate: AnyObject {
  func statusCheckTableViewCell(_ cell: StatusCheckTableViewCell, deleteButtonTapped sender: UIButton)
  
}
final class StatusCheckTableViewCell: UITableViewCell {
    
  // MARK: - IBOutlets
  
  @IBOutlet weak var nameLabel: UILabel! {
    didSet {
      nameLabel.textColor = #colorLiteral(red: 0.1411764706, green: 0.1568627451, blue: 0.2, alpha: 1)
      nameLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18.0)
    }
  }
  
  @IBOutlet weak var mobileNumberLabel: UILabel! {
    didSet {
      mobileNumberLabel.textColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
      mobileNumberLabel.font = UIFont(name: "AvenirNext-Medium", size: 12.0)
    }
  }
  
  @IBOutlet weak var riskLabel: UILabel! {
    didSet {
      riskLabel.font = UIFont(name: "AvenirNext-Bold", size: 12.0)
    }
  }
  
  @IBOutlet weak var nameInitialLetterLabel: UILabel! {
    didSet {
      nameInitialLetterLabel.font = UIFont(name: "AvenirNext-Bold", size: 18.0)
      nameInitialLetterLabel.textColor = UIColor.white
    }
  }
  
  @IBOutlet weak var menuButton: UIButton!
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var nameInitialLetterView: UIView! {
    didSet {
      nameInitialLetterView.layer.cornerRadius = 26.0
    }
  }
  
  @IBOutlet weak var userImageView: UIImageView! {
    didSet {
      userImageView.layer.cornerRadius = 26.0
    }
  }
  
  // MARK: - Public variables
  
  weak var delegate: StatusCheckTableViewCellDelegate?
  
  // MARK: - IBActions
  
  @IBAction func meunTapped(_ sender: UIButton) {
    delegate?.statusCheckTableViewCell(self, deleteButtonTapped: sender)
  }
  
  // MARK: - Public methods
  
  func configure(msmeRequest: StatusMsmeRequest) {
    
    if let name = msmeRequest.name, name.isEmpty == false {
      nameLabel.text = name
      nameLabel.isHidden = false
    }
    else {
      nameLabel.isHidden = true
    }
    
    mobileNumberLabel.text = msmeRequest.mobileNumber
    riskLabel.text = msmeRequest.message

    let color = msmeRequest.colorCode?.hexStringToUIColor()
    
    if let name = msmeRequest.name?.first?.uppercased(), name.isEmpty == false {
      nameInitialLetterLabel.text = name
      nameInitialLetterLabel.isHidden = false
      userImageView.isHidden = true
      nameInitialLetterView.backgroundColor = color
    }
    else {
      nameInitialLetterLabel.isHidden = true
      userImageView.isHidden = false
      nameInitialLetterView.backgroundColor = .white
    }
    
    
    riskLabel.textColor = color
    containerView.backgroundColor = color?.withAlphaComponent(0.10)
    menuButton.backgroundColor = color?.withAlphaComponent(0.01)
  }
}
