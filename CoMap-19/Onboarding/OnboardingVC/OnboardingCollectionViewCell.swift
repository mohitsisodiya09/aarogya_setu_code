//
//  OnboardingCollectionViewCell.swift
//  COVID-19
//

//

import UIKit

final class OnboardingCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var horizontalGroupImageView: UIImageView!
  @IBOutlet weak var verticalGroupImageView: UIImageView!
  
  @IBOutlet weak var topDescriptionLabel: UILabel! {
    didSet {
      topDescriptionLabel.adjustsFontSizeToFitWidth = true
      topDescriptionLabel.minimumScaleFactor = 0.5
      topDescriptionLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
    }
  }
  
  @IBOutlet weak var bottomDescriptionLabel: UILabel! {
    didSet {
      bottomDescriptionLabel.adjustsFontSizeToFitWidth = true
      bottomDescriptionLabel.minimumScaleFactor = 0.5
      bottomDescriptionLabel.font = UIFont(name: "AvenirNext-Medium", size: 16.0)
    }
  }
  
  @IBOutlet weak var topDescriptionView: UIView!
  @IBOutlet weak var bottomDescriptionView: UIView!
  
  @IBOutlet weak var topTriangleView: UIView!
  @IBOutlet weak var bottomTriangleView: UIView!
  
  private var tableArray: [String] = []
  
  enum Image {
    case setImage(image: UIImage)
    case setHorizontalImage(image: UIImage)
    case setVerticalImage(image: UIImage)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    topDescriptionView.isHidden = true
    bottomDescriptionView.isHidden = true
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.image = nil
    verticalGroupImageView.image = nil
    horizontalGroupImageView.image = nil
    
    topDescriptionLabel.text = nil
    bottomDescriptionLabel.text = nil
    
    topDescriptionView.isHidden = true
    bottomDescriptionView.isHidden = true
  }
  
  static let reuseIdentifier: String = "OnboardingCollectionViewCell"
  
  func setupUI(image: Image, topDescription: NSAttributedString?, topAccessibilityDescription: String?, bottomDescription: NSAttributedString?, bottomAccessibilityDescription: String?) {
    switch image {
    case .setImage(let image):
      self.imageView.image = image
      
    case .setVerticalImage(let image):
    self.verticalGroupImageView.image = image
      
    case .setHorizontalImage(let image):
      self.horizontalGroupImageView.image = image
    }
    
    topDescriptionLabel.attributedText = topDescription
    topDescriptionView.isHidden = topDescription == nil
    
    bottomDescriptionLabel.attributedText = bottomDescription
    bottomDescriptionView.isHidden = bottomDescription == nil
    
    topTriangleView.isHidden = topDescription == nil
    bottomTriangleView.isHidden = bottomDescription == nil
    
    topDescriptionLabel.accessibilityLabel = topAccessibilityDescription
    bottomDescriptionLabel.accessibilityLabel = bottomAccessibilityDescription
  }
  
}
