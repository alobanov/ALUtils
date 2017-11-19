//
//  NSManagedObject+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

//public typealias JSONDictionary = [String: Any]
//public typealias JSONArrayDictionary = [[String: Any]]
//
//public typealias DictionaryAnyObject = [String: AnyObject]
//public typealias DictionaryArray = [[String: AnyObject]]

public protocol NSManagedObjectMappable where Self:NSManagedObject {
  associatedtype Fields
  associatedtype Relations
  static func primaryKey() -> String
  func map(object: [String: Any], context: NSManagedObjectContext)
}

final public class EntityMapper<BaseType: NSManagedObjectMappable> {
  public static func map<T: NSManagedObjectMappable>(type:T.Type, object: [String: Any], context: NSManagedObjectContext) -> T {
    let key = T.primaryKey()
    let objects: [T] = NSManagedObject.createOrUpdateEntities(context: context, pkKey: key, pkValue: object[key] as? NSObject)
      
      for entity in objects {
        entity.map(object: object, context: context)
      }
      
      return objects.first!
  }
  
  private var context: NSManagedObjectContext

  public init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  // MARK: - Map relations
  public func mapRelationToOne<T: NSManagedObjectMappable>(relation: String, type: T.Type, object: [String: Any]) -> T?  {
    guard let relationKey = checkRelationKey(type: BaseType.self, relation: relation) else {
      return nil
    }
      var mapping: T?
      if let relationObj = object[relationKey] as? [String: Any] {
        mapping = EntityMapper.map(type: T.self, object: relationObj, context: context)
      } else {
        mapping = nil
      }
      return mapping
  }
  
  /// Map self object relation by node name `to-Many`
  public func mapRelationToMany<T: NSManagedObjectMappable>(relation: String, type: T.Type, object: [String: Any]) -> [T]?  {
    var mapping: [T]?
    guard let relationKey = checkRelationKey(type: BaseType.self, relation: relation) else {
      return nil
    }
    if let relationArr = object[relationKey] as? [[String: Any]] {
      let mapper = EntityMapper<T>(context: context)
      mapping = mapper.mapArray(objects: relationArr)
    } else {
      mapping = nil
    }
    return mapping
  }
  
  // MARK: Self Mapping
  
  /// Save self object
  public func mapSelf(object: [String: Any]) throws -> BaseType {
    let result: BaseType? = EntityMapper.map(type: BaseType.self, object: object, context: self.context)
    if let result = result {
      return result
    } else {
      throw(NSError(domain: "Error", code: 0, userInfo: nil))
    }
  }
  
  /// Save array
  ///
  /// - Returns: Observable of generic type
  public func mapArray(objects: [[String: Any]]) -> [BaseType] {
    var operations = [BaseType]()
    for obj in objects {
      let operation: BaseType = EntityMapper.map(type: BaseType.self, object: obj, context: context)
      operations.append(operation)
    }
    return operations
  }
  
  // MARK: - Private
  private func checkRelationKey<T: NSManagedObject>(type: T.Type, relation: String) -> String? {
    let entityName = String(describing: T.self)
    guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context),
      let relationDescription = entity.relationships().flatMap({ item -> NSRelationshipDescription? in
        return item.name == relation ? item : nil
      }).first
      else {
        return nil
    }
    let relationKey = relationDescription.customKey() ?? relation.toSnakeCase()
    return relationKey
  }
  
  deinit {
    print("dead EntityMapper")
  }
}
