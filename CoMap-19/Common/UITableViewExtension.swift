//
//  UITableViewExtension.swift
//  CoMap-19
//
//

import UIKit

extension UITableView {
  
  func isFirstRow(indexPath: IndexPath) -> Bool {
    let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: indexPath.section)
    let isFirstRow = indexPath.row == 0
    let isNumberOfRowsEmpty = numberOfRows == 0
    return !isNumberOfRowsEmpty && isFirstRow
  }
  
  func isLastRow(indexPath: IndexPath) -> Bool {
    
    let numberOfRows = self.dataSource?.tableView(self, numberOfRowsInSection: indexPath.section)
    
    if numberOfRows == 0 {
      return false
    }
    
    if let numberOfRows = numberOfRows, indexPath.row == numberOfRows - 1 {
      return true
    }
    
    return false
  }
}
