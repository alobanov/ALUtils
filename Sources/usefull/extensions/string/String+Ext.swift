//
//  String+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension String {
  func toSnakeCase() -> String {
    let pattern = "([a-z0-9])([A-Z])"
    var result = self
    do {
      let regex = try NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: self.count)
      result = regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    } catch { }
    return result
  }
}
