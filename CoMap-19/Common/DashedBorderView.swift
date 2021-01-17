//
//  DashedBorderView.swift
//  CoMap-19
//
//

import UIKit

public final class DashedBorderView: UIView {

  // MARK: - Public variables
  
  public enum Side {
    case top(inset: CGFloat, padding: CGFloat)
    case bottom(inset: CGFloat, padding: CGFloat)
    case left(inset: CGFloat, padding: CGFloat)
    case right(inset: CGFloat, padding: CGFloat)
    case all(insets: UIEdgeInsets)
    case midX, midY
  }

  public var side: Side
  public var dotColor: UIColor = #colorLiteral(red: 0.9176470588, green: 0.9607843137, blue: 1, alpha: 1)
  
  // MARK: - Private variables
  
  private var dotsPath = UIBezierPath()
  private var dashPattern: [CGFloat] = [4, 2]

  // MARK: - Initialization methods
  
  required init(for side: Side = .top(inset: 5, padding: 8),
                dashPattern: [CGFloat] = [4, 2],
                dotColor: UIColor = .gray) {
 
    self.side = side
    self.dashPattern = dashPattern
    self.dotColor = dotColor
    
    super.init(frame: .zero)
  }

  required init?(coder aDecoder: NSCoder) {
    side = .all(insets: .zero)
    super.init(coder: aDecoder)
  }

  // MARK: - View life cycle methods implementations
  
  override public func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    switch side {
    
    case let .top(inset, padding):
      dotsPath.move(to: .init(x: padding, y: inset))
      dotsPath.addLine(to: .init(x: bounds.width - padding, y: inset))
   
    case let .bottom(inset, padding):
      let yPoint = (bounds.height - inset)
      dotsPath.move(to: .init(x: padding, y: yPoint))
      dotsPath.addLine(to: .init(x: bounds.width - padding, y: yPoint))
    
    case let .left(inset, padding):
      dotsPath.move(to: .init(x: inset, y: padding))
      dotsPath.addLine(to: .init(x: inset, y: bounds.height - padding))
    
    case let .right(inset, padding):
      let xPoint = (bounds.width - inset)
      dotsPath.move(to: .init(x: xPoint, y: padding))
      dotsPath.addLine(to: .init(x: xPoint, y: bounds.height - padding))
    
    case .midX:
      dotsPath.move(to: .init(x: 0, y: bounds.midY))
      dotsPath.addLine(to: .init(x: bounds.maxX, y: bounds.midY))
    
    case .midY:
      dotsPath.move(to: .init(x: bounds.midX, y: 0))
      dotsPath.addLine(to: .init(x: bounds.midX, y: bounds.maxY))
    
    case .all(let insets):
      dotsPath = UIBezierPath(roundedRect: bounds.inset(by: insets), cornerRadius: 0)
    }

    context.saveGState()
    context.setStrokeColor(dotColor.cgColor)
    context.setLineWidth(2)
    context.setLineDash(phase: 0, lengths: dashPattern)
    context.addPath(dotsPath.cgPath)
    context.strokePath()
    context.restoreGState()
  }
}
