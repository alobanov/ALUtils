//
//  Date+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 06/04/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Date {
  func iso8601(format: String?, gmtFromZero: Bool) -> String? {
    let frmttr = gmtFromZero ? DateFormatter.frmttrGMT0 : DateFormatter.frmttr
    frmttr.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    return frmttr.string(from: self)
  }
}

public extension String {
  func iso8601(format: String?, gmt: Bool) -> Date? {
    let frmttr = gmt ? DateFormatter.frmttrGMT0 : DateFormatter.frmttr
    frmttr.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
    return frmttr.date(from: self)
  }
}
