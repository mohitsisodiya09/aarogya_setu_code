//
//  CustomeProgressView.swift
//  
//
//

import UIKit

final class MenuIconView: UIView {

  // MARK: - Private Properties

  fileprivate let nibName: String = "MenuIconView"

  // MARK: - IBOutlets
  
  @IBOutlet weak var dotView: UIView! {
    didSet {
      dotView.layer.cornerRadius = 4.0
    }
  }
  
  @IBOutlet weak var contentView: UIView!

  // MARK: - Initalization Methods Implementation

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupXib()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupXib()
  }

  // MARK: - Private Methods

  fileprivate func setupXib() {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: nibName, bundle: bundle)

    guard let view  = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
      fatalError("Cannot load Nib \(nibName)")
    }

    view.frame = self.bounds
    view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
    addSubview(view)
  }

  // MARK: - Public Methods

  func configure(shouldShowDot: Bool) {
    dotView.isHidden = !shouldShowDot
  }
}
