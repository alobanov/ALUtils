//
//  NSManagedObject+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
  class func verifyContextSafety(context: NSManagedObjectContext) {
    if Thread.isMainThread && context.concurrencyType == .privateQueueConcurrencyType {
      fatalError("Background context used in the main thread. Use context's `perform` method")
    }
    
    if !Thread.isMainThread && context.concurrencyType == .mainQueueConcurrencyType {
      fatalError("Main context used in a background thread. Use context's `perform` method.")
    }
  }
  
  public class func delete(_ id: Any, primaryKey: String, inEntityNamed entityName: String, using context: NSManagedObjectContext) throws {
    NSManagedObject.verifyContextSafety(context: context)
    
    guard NSEntityDescription.entity(forEntityName: entityName, in: context) != nil else { abort() }
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "%K = %@", primaryKey, id as! NSObject)
    
    let objects = try context.fetch(fetchRequest)
    guard objects.count > 0 else { return }
    
    for deletedObject in objects {
      context.delete(deletedObject)
    }
  }
  
  static func createOrUpdateEntities<ResultType: NSManagedObject>(context: NSManagedObjectContext, pkKey: String, pkValue: NSObject?) throws -> [ResultType] {
    NSManagedObject.verifyContextSafety(context: context)
    
    let entityName = String(describing: ResultType.self)
    
    guard let id = pkValue else {
      throw NSError.define(description: "Couldn't find primary key \(pkKey) in JSON for object in entity \(entityName)")
    }
    
    do {
      let fetchRequest = NSFetchRequest<ResultType>(entityName: entityName)
      fetchRequest.predicate = NSPredicate(format: "%K = %@", pkKey, id)
      
      let fetchedObjects = try context.fetch(fetchRequest)
      let insertedOrUpdatedObjects: [ResultType]
      if fetchedObjects.count > 0 {
        insertedOrUpdatedObjects = fetchedObjects
      } else {
        let inserted = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! ResultType
        insertedOrUpdatedObjects = [inserted]
      }
      
      return insertedOrUpdatedObjects
    } catch {
      abort()
    }
  }
}