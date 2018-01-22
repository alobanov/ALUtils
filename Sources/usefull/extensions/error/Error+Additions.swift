//
//  Error+Additions.swift
//  ALUtils
//
//  Created by Aleksey Lobanov on 16/06/2017.
//  Copyright © 2017 ALUtils. All rights reserved.
//

import Foundation

public extension NSError {
  public static func define(description: String, failureReason: String = "", code: Int = 1) -> NSError {
    let userInfo = [
      NSLocalizedDescriptionKey: description,
      NSLocalizedFailureReasonErrorKey: failureReason
    ]
    
    return NSError(domain: "ru.alobanov", code: code, userInfo: userInfo)
  }
}
