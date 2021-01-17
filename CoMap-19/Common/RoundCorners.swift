//
//  RoundCorners.swift
//  CoMap-19
//
//

import UIKit

class RoundCorners: UIView {
  
  // MARK: - View Life cycle methods
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.roundCorners([.topLeft, .topRight], radius: 10)
  }
  
  // MARK: - Private methods
  
  fileprivate func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
  
}
