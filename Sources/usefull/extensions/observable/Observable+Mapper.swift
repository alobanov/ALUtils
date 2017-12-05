//
//  Observable+Mapper.swift
//  Puls
//
//  Created by MOPC on 29/06/2017.
//  Copyright © 2017 MOPC. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import SwiftyJSON

public func resultFromJSON<T: Mappable>(_ object: [String: AnyObject], classType: T.Type) -> T? {
  return Mapper<T>().map(JSON: object)
}

public extension Observable {
  func mapDictionaryToModel<T: Mappable>(_ type: T.Type, byPath: [JSONSubscriptType]? = nil) -> Observable<T?> {
    return map({ representor in
      
      guard let json = representor as? DictionaryAnyObject else {
        return nil
      }
      
      var mutableJSON = json
      
      if let path = byPath {
        if let nestedObject: DictionaryAnyObject = try json.find(by: path) {
          mutableJSON = nestedObject
        }
      }
      
      guard let obj: T = resultFromJSON(mutableJSON, classType: type) else {
        throw NSError.define(description: "Error with serealization: \(String(describing: T.self))")
      }
      
      return obj
    })
  }
  
  func mapDictionaryToArrayModels<T: Mappable>(_ type: T.Type, nodePath: [JSONSubscriptType]? = nil) -> Observable<[T]> {
    return transformToArray(nodePath: nodePath)
      .map({ array in
        var result: [T] = []
        for json in array {
          if let obj: T = resultFromJSON(json, classType: type) {
            result.append(obj)
          }
        }
        return result
    })
  }
    
  func transformToArray(nodePath: [JSONSubscriptType]? = nil) -> Observable<DictionaryArray> {
    return map { representor in
      
      if let path = nodePath {
        guard let object = representor as? DictionaryAnyObject else {
          throw NSError.define(description: "No responese from server")
        }
        
        guard let array: DictionaryArray = try object.find(by: path) else {
          throw NSError.define(description: "No responese from server")
        }
        
        return array
      } else {
        guard let array = representor as? DictionaryArray else {
          throw NSError.define(description: "No responese from server")
        }
        
        return array
      }
      
    }
  }
  
//  func transformResponseToDictionary(nodePath: [JSONSubscriptType]? = nil) -> Observable<DictionaryAnyObject> {
//    return map { representor in
//      guard let response = representor as? Response else {
//        throw NSError.define(description: "No responese from server")
//      }
//      
//      guard let json: DictionaryAnyObject = try response.data.toJSON() else {
//        throw NSError.define(description: "No responese from server")
//      }
//      
//      if let path = nodePath {
//        guard let findedNode: DictionaryAnyObject = try json.find(by: path) else {
//          throw NSError.define(description: "No responese from server")
//        }
//        
//        return findedNode
//      }
//      
//      return json
//    }
//  }
//    
//  func mapResponceToDictonary(byPath: [JSONSubscriptType]? = nil) -> Observable<JSONDictionary> {
//    return transformResponseToDictionary()
//      .map { json in
//
//        if let path = byPath {
//          guard let nestedObject: DictionaryAnyObject = try json.find(by: path) else {
//            return json
//          }
//
//          return nestedObject
//        }
//
//        return json
//    }
//  }
//
//  func mapResponceToArrayDictonary(byPath: [JSONSubscriptType]) -> Observable<JSONArrayDictionary> {
//    return transformResponseToDictionary()
//      .map { json in
//        guard let nestedObject: DictionaryArray = try json.find(by: byPath) else {
//          return []
//        }
//        return nestedObject
//      }
//  }
}

