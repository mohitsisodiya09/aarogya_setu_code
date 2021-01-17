//
//  PermissionScreenPermissionTableViewCell.swift
//  CoMap-19
//
//
//

import UIKit

class PermissionScreenPermissionTableViewCell: UITableViewCell {

  @IBOutlet weak var iconImageView: UIImageView!
  
  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 14)

    }
  }
  
  @IBOutlet weak var subtitleLabel: UILabel! {
  didSet {
    subtitleLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
  }
  }
  
  func configure(title: String, subtitle: String, accessibilityTitle: String, accessibilitySubtitle: String) {
    titleLabel.text = title
    subtitleLabel.text = subtitle
    
    titleLabel.accessibilityLabel = accessibilityTitle
    subtitleLabel.accessibilityLabel = accessibilitySubtitle
  }
  
  func getImageFromDirectory (_ imageName: String) -> UIImage? {

      if let fileURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(imageName).png") {
          // get the data from the resulting url
          var imageData : Data?
          do {
               imageData = try Data(contentsOf: fileURL)
          }
          catch {
              return nil
          }
          guard let dataOfImage = imageData else { return nil }
          guard let image = UIImage(data: dataOfImage) else { return nil }
          return image
      }
      return nil
  }
    
}
