//
//  Error+Additions.swift
//  ALUtils
//
//  Created by Aleksey Lobanov on 16/06/2017.
//  Copyright © 2017 ALUtils. All rights reserved.
//

import Foundation

public extension NSError {
  public static func define(description: String, failureReason: String = "", code: Int = 0) -> NSError {
    let userInfo = [
      NSLocalizedDescriptionKey: description,
      NSLocalizedFailureReasonErrorKey: failureReason
    ]
    
    let domain = Bundle.main.bundleIdentifier ?? "ru.alutils"
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}
