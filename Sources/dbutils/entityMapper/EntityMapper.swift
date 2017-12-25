//
//  NSManagedObject+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

public protocol NSManagedObjectMappable where Self:NSManagedObject {
  associatedtype Fields
  associatedtype Relations
  static func primaryKey() -> String
  func map(object: [String: Any], context: NSManagedObjectContext) throws
}

public class EntityMapper<BaseType: NSManagedObjectMappable> {
  public static func map<T: NSManagedObjectMappable>(type:T.Type, object: [String: Any], context: NSManagedObjectContext) throws -> T {
    let key = T.primaryKey()
    do {
      let objects: [T] = try T.createOrUpdateEntities(context: context, pkKey: key, id: object[key] ?? 0)
      
      for entity in objects {
        try entity.map(object: object, context: context)
      }
      
      return objects.first!
    } catch (let e) {
      throw e as NSError
    }
  }
  
  private var context: NSManagedObjectContext

  public init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  // MARK: - Map relations
  public func mapRelationToOne<T: NSManagedObjectMappable>(relation: String, type: T.Type, object: [String: Any]) throws -> T?  {
    guard let relationKey = checkRelationKey(type: BaseType.self, relation: relation) else {
      return nil
    }
    
    var mapping: T?
    if let relationObj = object[relationKey] as? [String: Any] {
      do {
        mapping = try EntityMapper.map(type: T.self, object: relationObj, context: context)
      } catch (let e) {
        throw e as NSError
      }
    } else {
      mapping = nil
    }
    return mapping
  }
  
  /// Map self object relation by node name `to-Many`
  public func mapRelationToMany<T: NSManagedObjectMappable>(relation: String, type: T.Type, object: [String: Any]) throws -> [T]?  {
    var mapping: [T]?
    guard let relationKey = checkRelationKey(type: BaseType.self, relation: relation) else {
      return nil
    }
    do {
      if let relationArr = object[relationKey] as? [[String: Any]] {
        let mapper = EntityMapper<T>(context: context)
        mapping = try mapper.mapArray(objects: relationArr)
      } else {
        mapping = nil
      }
      return mapping
    } catch (let e) {
      throw e as NSError
    }
  }
  
  // MARK: Self Mapping
  
  /// Save self object
  public func mapSelf(object: [String: Any]) throws -> BaseType {
    do {
      let result: BaseType? = try EntityMapper.map(type: BaseType.self, object: object, context: self.context)
      if let result = result {
        return result
      } else {
        throw ORMError.failedMapObject(objectTypeStr: "\(BaseType.self)").error
      }
    } catch (let e) {
      throw e as NSError
    }
  }
  
  /// Save array
  ///
  /// - Returns: Observable of generic type
  @discardableResult public func mapArray(objects: [[String: Any]]) throws -> [BaseType] {
    do {
      var operations = [BaseType]()
      for obj in objects {
        let operation: BaseType = try EntityMapper.map(type: BaseType.self, object: obj, context: context)
        operations.append(operation)
      }
      return operations
    } catch (let e) {
      throw e as NSError
    }
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
}
