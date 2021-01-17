//
//  ContainerController.swift
//  CoMap-19
//

//
//

import UIKit

final class ContainerController: UIViewController {
    
  // MARK: - Private variables
  
  fileprivate var menuController: MenuController?
  fileprivate var centerController: UINavigationController?
  fileprivate var isExpanded = false
  
  // MARK: - View Life cycle methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureHomeController()
  }
  
  // MARK: - Handlers
  
  func configureHomeController() {
    
    let storyboard = UIStoryboard(name: Constants.Storyboard.main, bundle: nil)
     
    if let homeController = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.homeScreen) as? HomeScreenViewController {
      homeController.delegate = self
      centerController = UINavigationController(rootViewController: homeController)
     
      if let centerController = centerController {
        view.addSubview(centerController.view)
        addChild(centerController)
        centerController.didMove(toParent: self)
      }
    }
  }
  
  func configureMenuController() {
    if menuController == nil {
     
      let storyboard = UIStoryboard(name: Constants.Storyboard.main, bundle: nil)
      
      if let menuController = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.menu) as? MenuController {
        self.menuController = menuController
        self.menuController?.delegate = self
        menuController.view.frame.origin.x = -UIScreen.main.bounds.width
        view.insertSubview(menuController.view, at: 0)
        addChild(menuController)
        view.bringSubviewToFront(menuController.view)
        menuController.didMove(toParent: self)
      }
    }
  }
  
  func showMenuController(shouldExpand: Bool) {
    
    if shouldExpand {
      UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
        self.menuController?.view.frame.origin.x = 0
      }, completion: nil)
      
      UIView.animate(withDuration: 0.5) {
        self.menuController?.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
      }
    }
    else {
      self.menuController?.view.backgroundColor = UIColor.clear
      UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
        self.menuController?.view.frame.origin.x = -UIScreen.main.bounds.width
      }, completion: nil)
    }
  }
}

// MARK: - HomeScreenViewControllerDelegate methods implementations

extension ContainerController: HomeScreenViewControllerDelegate {
 
  func homeScreenViewController(_ vc: HomeScreenViewController, menuButtonTapped sender: UIBarButtonItem) {
    
    if !isExpanded {
      configureMenuController()
    }
    
    isExpanded = !isExpanded
    showMenuController(shouldExpand: isExpanded)
  }
}

// MARK: - MenuControllerDelegate
extension ContainerController: MenuControllerDelegate {
  
  func hideMenuButtonTapped(_ sender: UIButton) {
    isExpanded = !isExpanded
    showMenuController(shouldExpand: isExpanded)
  }
  
}
