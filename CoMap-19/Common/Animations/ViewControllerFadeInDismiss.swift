//
//  ViewControllerFadeInDismiss.swift
//

//
//

import UIKit

fileprivate struct Defaults {
  static let fromViewControllerAnimationDuration: TimeInterval = 0.25
}

class ViewControllerFadeInDismiss: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Defaults.fromViewControllerAnimationDuration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    if let fromViewController = transitionContext.viewController(forKey: .from),
      let fromView = fromViewController.view {

      let animationDuration = transitionDuration(using: transitionContext)

      UIView.animate(withDuration: animationDuration,
                     animations: {
                      fromView.alpha = 0.0
      }, completion: { finished in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }

}
