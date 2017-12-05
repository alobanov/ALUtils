//
//  Dictionary+Ext.swift
//  Pulse
//
//  Created by MOPC on 19.04.17.
//  Copyright © 2017 MOPC Lab. All rights reserved.
//

import Foundation
import SwiftyJSON

public extension Dictionary {
  func setOrUpdate(value: Any, path: String) -> [String: Any] {
    let keys = path.components(separatedBy: ".")
    var json = JSON(self)

    var keyStack: [String] = []
    var deep = 1

    for key in keys {
      keyStack.append(key)

      if deep == keys.count {
        json[keyStack] = JSON(value)
      } else {
        if json[keyStack].dictionary == nil {
          json[keyStack] = JSON([keys[deep]: ""])
        }
      }

      deep+=1
    }

    return json.dictionaryObject!
  }

  func value(by path: String) -> Any? {
    let keys = path.components(separatedBy: ".")

    let count = keys.count
    var deep = 1

    guard var currentNode = self as? JSONDictionary else {
      return nil
    }

    for key in keys {
      if deep == count {

        if (currentNode[key] as? NSNull) != nil {
          return nil
        }

        if let array = currentNode[key] as? [JSONDictionary] {
          return array
        }

        if let dict = currentNode[key] as? JSONDictionary {
          return dict
        }

        if let result = currentNode[key] {
          let result = String(describing: result)
          return result
        } else {
          return nil
        }
      } else {
        if let nextNode = currentNode[key] as? JSONDictionary {
          currentNode = nextNode
        }
      }
      deep+=1
    }

    return nil
  }

  func find<T>(by path: [JSONSubscriptType]) throws -> T {
    let json = JSON(self)
    if let d = json[path].object as? T {
      return d
    } else {
      throw NSError.define(description: "Resources.Data.\(path) is empty or is not an Object")
    }
  }
}
