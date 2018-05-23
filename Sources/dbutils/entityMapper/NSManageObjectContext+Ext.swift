//
//  NSManageObjectContext+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 01/02/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {

  public func safeObject(_ entityName: String, pKey: String, value: Any) -> NSManagedObject? {
    var result: NSManagedObject?
    
    if let value = value as? NSObject {
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
      request.predicate = NSPredicate(format: "%K = %@", pKey, value)
      do {
        let objects = try fetch(request)
        result = objects.first as? NSManagedObject
      } catch {
        fatalError("Failed to fetch request for entityName: \(entityName), predicate: \(String(describing: request.predicate))")
      }
    }
    
    return result
  }
  
  @discardableResult public func mapObject<MapType:NSManagedObjectMappable>(type: MapType.Type, from json: [String: Any]) throws -> MapType {
    do {
      let entityName = String(describing: MapType.self)
      let pKey = MapType.primaryKey()
      guard let pKeyValue = json[pKey] else {
        throw NSError.define(description: "json doesn't contain value for primary key \(pKey)")
      }
      let mo = safeObject(entityName, pKey: pKey, value: pKeyValue) ?? NSEntityDescription.insertNewObject(forEntityName: entityName, into: self)
      if let typedMo = mo as? MapType {
        try typedMo.map(from: json)
        return typedMo
      } else {
        throw NSError.define(description: "entity \(mo) dosent conform to NSManagedObjectMappable protocol")
      }
    } catch (let e) {
      throw e as NSError
    }
  }
  
  @discardableResult public func mapArray<MapType: NSManagedObjectMappable>(type: MapType.Type, from objects: [[String: Any]]) throws -> [MapType] {
    do {
      var operations = [MapType]()
      for obj in objects {
        let operation: MapType = try mapObject(type: MapType.self, from: obj)
        operations.append(operation)
      }
      return operations
    } catch (let e) {
      throw e as NSError
    }
  }
  
  public func delete(pkValue: NSObject, pkName: String, inEntityNamed entityName: String) throws {
    guard NSEntityDescription.entity(forEntityName: entityName, in: self) != nil else {
      throw NSError.define(description: "Failed to retrive entity named \(entityName)")
    }
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "%K = %@", pkName, pkValue)
    
    let objects = try self.fetch(fetchRequest)
    guard objects.count > 0 else { return }
    
    for deletedObject in objects {
      self.delete(deletedObject)
    }
  }
  
}
