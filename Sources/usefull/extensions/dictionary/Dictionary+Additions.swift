//
//  Dictionary+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 05.12.2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Dictionary {
  mutating func merge(with dictionary: Dictionary) {
    dictionary.forEach { updateValue($1, forKey: $0) }
  }
  
  func merged(with dictionary: Dictionary) -> Dictionary {
    var copy = self
    dictionary.forEach { copy.updateValue($1, forKey: $0) }
    return copy
  }
  
  func nullKeyRemoval() -> [AnyHashable: Any] {
    var dict: [AnyHashable: Any] = self
    
    let keysToRemove = dict.keys.filter { dict[$0] is NSNull }
    let keysToCheck = dict.keys.filter({ dict[$0] is Dictionary })
    for key in keysToRemove {
      dict.removeValue(forKey: key)
    }
    for key in keysToCheck {
      if let valueDict = dict[key] as? [AnyHashable: Any] {
        dict.updateValue(valueDict.nullKeyRemoval(), forKey: key)
      }
    }
    return dict
  }
}

public extension Dictionary where Key == String {
  func date(by key: String, dateFormat: String?, gmt: Bool) -> Date? {
    if let value = self[key] as? String {
      return value.iso8601(format: dateFormat ?? "yyyy-MM-dd'T'HH:mm:ssZZZZ", gmt: gmt)
    } else {
      return nil
    }
  }
  
  func string(by key: String) -> String? {
    return self[key] as? String
  }
  
  func int(by key: String) -> Int? {
    if let f = self[key] as? Int {
      return f
    }
    
    if let value = self[key] as? String {
      return Int(value)
    }
    
    return nil
  }
  
  func float(by key: String) -> Float? {
    if let f = self[key] as? Double {
      return Float(f)
    }
    
    if let value = self[key] as? String {
      return Float(value)
    }
    
    return nil
  }
  
  func double(by key: String) -> Double? {
    if let f = self[key] as? Double {
      return f
    }
    
    if let value = self[key] as? String {
      return Double(value)
    }
    
    return nil
  }
  
  func decimal(by key: String) -> NSDecimalNumber? {
    if let f = self[key] as? Double {
      return NSDecimalNumber(value: f)
    }
    
    if let value = self[key] as? String {
      return NSDecimalNumber(string: value)
    }
    
    return nil
  }
  
  func data(by key: String) -> Data? {
    if let raw = self[key] {
      return NSKeyedArchiver.archivedData(withRootObject: raw)
    } else {
      return nil
    }
  }
  
  func bool(by key: String) -> Bool? {
    if let f = self[key] as? Bool {
      return f
    }
    
    if let value = self[key] as? String {
      return Bool(value)
    }
    
    return nil
  }
}
