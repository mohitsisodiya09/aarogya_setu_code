//
//  ViewControllerFadeInPresentation.swift
//

//
//

import UIKit

fileprivate struct Defaults {
  static let toViewControllerAnimationDuration: TimeInterval = 0.25
}

class ViewControllerFadeInPresentation: NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return Defaults.toViewControllerAnimationDuration
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    if let toViewController = transitionContext.viewController(forKey: .to),
      let toView = toViewController.view {
      
      let animationDuration = transitionDuration(using: transitionContext)

      let containerView = transitionContext.containerView
      containerView.addSubview(toView)
      
      toView.frame = containerView.frame
      toView.alpha = 0.0

      UIView.animate(withDuration: animationDuration,
                     animations: {
                      toView.alpha = 1.0
      }, completion: { finished in
        transitionContext.completeTransition(finished)
      })
    }
  }

}
