//
//  ViewControllerBottomToTopPresentation.swift
//

//
//

import UIKit

fileprivate struct Defaults {
  static let destinationViewControllerAnimationDuration: TimeInterval = 0.4
  static let sourceViewControllerAlpha: CGFloat = 0.4
}

class ViewControllerBottomToTopPresentation: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Defaults.destinationViewControllerAnimationDuration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    if let toViewController = transitionContext.viewController(forKey: .to),
       let toView = toViewController.view {

      let animationDuration = transitionDuration(using: transitionContext)
      let containerView = transitionContext.containerView
      
      UIView.animate(withDuration: Defaults.destinationViewControllerAnimationDuration) {
        containerView.backgroundColor = UIColor.clear.withAlphaComponent(Defaults.sourceViewControllerAlpha)
      }

      containerView.addSubview(toView)
      toView.frame = CGRect(x: containerView.frame.origin.x,
                            y: UIScreen.main.bounds.size.height,
                            width: containerView.frame.size.width,
                            height: containerView.frame.size.height)

      UIView.animate(withDuration: animationDuration,
                     animations: {
                      toView.frame.origin.y = 0.0
      }, completion: { finished in
        transitionContext.completeTransition(finished)
      })
    }
  }

}
