//
//  Formatter+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 08.12.2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Formatter {
  static let frmttrGMT0: DateFormatter = {
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
  
  static let fiat: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = " "
    formatter.numberStyle = .decimal
    formatter.roundingMode = NumberFormatter.RoundingMode.floor
    formatter.decimalSeparator = "."
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter
  }()
  
  static let crypto: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = " "
    formatter.numberStyle = .decimal
    formatter.roundingMode = NumberFormatter.RoundingMode.floor
    formatter.minimumFractionDigits = 4
    formatter.maximumFractionDigits = 8
    formatter.decimalSeparator = "."
    return formatter
  }()
}
