//
//  NavigationBarExtension.swift
//  CoMap-19
//

//
//

import UIKit

extension UINavigationBar {
    func transparentNavigationBar() {
    self.setBackgroundImage(UIImage(), for: .default)
    self.shadowImage = UIImage()
    self.isTranslucent = true
    }
}
