//
//  TriangleView.swift
//  CoMap-19
//

//
//

import UIKit

class TriangleView : UIView {
  
  @IBInspectable var upsideDown: Bool = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func draw(_ rect: CGRect) {
    
    guard let context = UIGraphicsGetCurrentContext() else { return }
    
    context.beginPath()
    
    if upsideDown {
      context.move(to: CGPoint(x: rect.maxX, y: rect.minY))
      context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    }
    else {
      context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
      context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
      context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
    }
    
    context.closePath()
    
    context.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    context.fillPath()
  }
}
