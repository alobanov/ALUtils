//
//  Formatter+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 08.12.2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Formatter {
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
  }()
}

public extension Date {
  func iso8601(format: String?) -> String? {
    let frmt = Formatter.iso8601
    frmt.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    return frmt.string(from: self)
  }
  
  var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }
}

public extension String {
  func iso8601(format: String?) -> Date? {
    let frmt = Formatter.iso8601
    frmt.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    return frmt.date(from: self)
  }
  
  var dateFromISO8601: Date? {
    return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
  }
}
