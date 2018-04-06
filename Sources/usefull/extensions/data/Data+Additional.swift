//
//  Data+Additional.swift
//  ALUtils
//
//  Created by Aleksey Lobanov on 03/08/2017.
//  Copyright © 2017 ALUtils. All rights reserved.
//

import Foundation

public extension Data {
  func toJSON() throws -> DictionaryAnyObject? {
    guard let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? DictionaryAnyObject else {
      throw NSError.define(description: "NSData could not serialized to JSON")
    }
    
    return json
  }
  
  func toJSONArray() throws -> DictionaryArray? {
    guard let array = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? DictionaryArray else {
      throw NSError.define(description: "NSData could not serialized to JSON")
    }
    
    return array
  }
}
