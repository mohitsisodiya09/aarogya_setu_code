//
//  Localize.swift
//  CoMap-19
//

//
//

import UIKit

final class Localize: NSObject {
  
  private static let APPLE_LANGUAGE_KEY = "AppleLanguages"
  
  static func currentAppleLanguage() -> String{
    let userdef = UserDefaults.standard
    let langArray = userdef.object(forKey: Localize.APPLE_LANGUAGE_KEY) as! NSArray
    let current = langArray.firstObject as! String
    let endIndex = current.startIndex
    
    let currentWithoutLocale = current[..<current.index(endIndex, offsetBy: 2)]
    return String(currentWithoutLocale)
  }
  
  static func currentAppleLanguageFull() -> String{
    let userdef = UserDefaults.standard
    let langArray = userdef.object(forKey: Localize.APPLE_LANGUAGE_KEY) as! NSArray
    let current = langArray.firstObject as! String
    return current
  }
  
  static func setAppleLanguageTo(lang: String) {
    let userdef = UserDefaults.standard
    userdef.set([lang,currentAppleLanguage()], forKey: Localize.APPLE_LANGUAGE_KEY)
    userdef.synchronize()
  }
  
  class func setup() {
    MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(_:value:table:)))
  }
}

fileprivate func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
  let origMethod: Method = class_getInstanceMethod(cls, originalSelector)!;
  let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector)!;
  if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
    class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
  } else {
    method_exchangeImplementations(origMethod, overrideMethod);
  }
}

extension Bundle {
  @objc func specialLocalizedStringForKey(_ key: String, value: String?, table tableName: String?) -> String {
    if self == Bundle.main {
      let currentLanguage = Localize.currentAppleLanguage()
      var bundle = Bundle();
      if let _path = Bundle.main.path(forResource: Localize.currentAppleLanguageFull(), ofType: "lproj") {
        bundle = Bundle(path: _path)!
      }else
        if let _path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
          bundle = Bundle(path: _path)!
        } else {
          let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
          bundle = Bundle(path: _path)!
      }
      return (bundle.specialLocalizedStringForKey(key, value: value, table: tableName))
    } else {
      return (self.specialLocalizedStringForKey(key, value: value, table: tableName))
    }
  }
}
