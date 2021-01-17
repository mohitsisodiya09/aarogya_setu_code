//
//  ViewControllerBottomToTopDismiss.swift
//

//
//

import UIKit

fileprivate struct Defaults {
  static let fromViewControllerAnimationDuration: TimeInterval = 0.4
  static let toViewControllerAnimationDuration: TimeInterval = 0.2
  static let toViewControllerAlpha: CGFloat = 1.0
}

class ViewControllerBottomToTopDismiss: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Defaults.fromViewControllerAnimationDuration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    if let fromViewController = transitionContext.viewController(forKey: .from),
       let toViewController = transitionContext.viewController(forKey: .to),
       let fromView = fromViewController.view {

      UIView.animate(withDuration: Defaults.toViewControllerAnimationDuration, animations: {
        toViewController.view.alpha = Defaults.toViewControllerAlpha
      })

      let animationDuration = transitionDuration(using: transitionContext)

      UIView.animate(withDuration: animationDuration,
                     animations: {
                      fromView.frame.origin.y = UIScreen.main.bounds.size.height
      }, completion: { finished in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }

}
