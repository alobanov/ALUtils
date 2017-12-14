//
//  NSManagedObject+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObject {
  public class func verifyContextSafety(context: NSManagedObjectContext) {
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
  
  public class func createOrUpdateEntities<ResultType: NSManagedObject>(context: NSManagedObjectContext, pkKey: String, id: Any) throws -> [ResultType] {
    NSManagedObject.verifyContextSafety(context: context)
    
    let entityName = String(describing: ResultType.self)
    
    do {
      let fetchRequest = NSFetchRequest<ResultType>(entityName: entityName)
      let predicate = NSPredicate(format: "%K = %@", pkKey, id as! NSObject)
      fetchRequest.predicate = predicate
      
      let fetchedObjects = try context.fetch(fetchRequest)
      let insertedOrUpdatedObjects: [ResultType]
      if fetchedObjects.count > 0 {
        insertedOrUpdatedObjects = fetchedObjects
//        if fetchedObjects.count > 1 {
//          for (index, ent) in fetchedObjects.enumerated() {
//            if index > 0 {
//              context.delete(ent)
//            }
//          }
//        }
      } else {
        let inserted = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as! ResultType
        insertedOrUpdatedObjects = [inserted]
      }
      
      if context.hasChanges {
        try context.save()
      }
      
      return insertedOrUpdatedObjects
    } catch {
      abort()
    }
  }
}
