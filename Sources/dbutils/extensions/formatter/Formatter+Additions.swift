//
//  Formatter+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 08.12.2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Formatter {
  static let frmttrGMT: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
  
  static let frmttr: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

public extension Date {
  func iso8601(format: String?, gmt: Bool) -> String? {
    let frmttr = gmt ? DateFormatter.frmttrGMT : DateFormatter.frmttr
    frmttr.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    return frmttr.string(from: self)
  }
}

public extension String {
  func iso8601(format: String?, gmt: Bool) -> Date? {
    let frmttr = gmt ? DateFormatter.frmttrGMT : DateFormatter.frmttr
    frmttr.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    return frmttr.date(from: self)
  }
}
