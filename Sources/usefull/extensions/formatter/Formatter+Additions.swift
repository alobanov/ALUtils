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
  
  static let currencyFiat: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = " "
    formatter.numberStyle = .decimal
    formatter.decimalSeparator = "."
    formatter.maximumFractionDigits = 2
    return formatter
  }()
  
  static let currencyCrypto: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.groupingSeparator = " "
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 8
    formatter.decimalSeparator = "."
    return formatter
  }()
}
