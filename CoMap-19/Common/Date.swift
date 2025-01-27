//
//  Date.swift
//  CoMap-19
//

//
//

import Foundation

extension Date {
  /// Returns the amount of years from another date
  func years(from date: Date) -> Int {
    return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
  }
  /// Returns the amount of months from another date
  func months(from date: Date) -> Int {
    return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
  }
  /// Returns the amount of weeks from another date
  func weeks(from date: Date) -> Int {
    return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
  }
  /// Returns the amount of days from another date
  func days(from date: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
  }
  /// Returns the amount of hours from another date
  func hours(from date: Date) -> Int {
    return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
  }
  /// Returns the amount of minutes from another date
  func minutes(from date: Date) -> Int {
    return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
  }
  /// Returns the amount of seconds from another date
  func seconds(from date: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
  }
  /// Returns the a custom time interval description from another date
  func offset(from date: Date) -> String {
    if years(from: date)   > 0 { return "\(years(from: date))y"   }
    if months(from: date)  > 0 { return "\(months(from: date))M"  }
    if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
    if days(from: date)    > 0 { return "\(days(from: date))d"    }
    if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
    if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
    if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
    return ""
  }
  
  func toString() -> String {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormat.string(from: self)
  }
  
  func toString(format: String) -> String {
   let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: Localize.currentAppleLanguage())
    return formatter.string(from: self)
  }
  
  func difference(ofComponent component: Calendar.Component, fromDate date: Date) -> Int {
    let calendar = Calendar.getUTCCalender()
    
    guard let start = calendar.ordinality(of: component, in: .era, for: date),
      let end = calendar.ordinality(of: component, in: .era, for: self) else {
        return 0
    }
    
    return end - start
  }
}

extension Calendar {
  
  static func getUTCCalender() -> Calendar {
    var currentCalender = self.current
    if let utcTimeZone = TimeZone(abbreviation: "UTC") {
      currentCalender.timeZone = utcTimeZone
    }
    
    return currentCalender
  }
    
}
