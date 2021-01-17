//
//  String.swift
//  CoMap-19
//

//
//

import UIKit

extension String {
  
  func isNumber() -> Bool {
    return NumberFormatter().number(from: self) != nil
  }

  func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = format
    dateFormat.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormat.date(from: self)
  }
  
  func toDouble() -> Double {
    return Double(self) ?? 0.0
  }
  
  func toFloat() -> Float {
    return Float(self) ?? 0.0
  }
  
  func hexStringToUIColor () -> UIColor {
    var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
      return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
  
  func image() -> UIImage? {
    let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    let nameLabel = UILabel(frame: frame)
    nameLabel.textAlignment = .center
    nameLabel.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    nameLabel.textColor = .white
    nameLabel.font = UIFont(name: "AvenirNext-Bold", size: 64.0)
    nameLabel.text = self.uppercased()
    UIGraphicsBeginImageContext(frame.size)
    if let currentContext = UIGraphicsGetCurrentContext() {
      nameLabel.layer.render(in: currentContext)
      let nameImage = UIGraphicsGetImageFromCurrentImageContext()
      return nameImage
    }
    return nil
  }
}
