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
  /**
   Safely fetches a NSManagedObject in the current context. If no localPrimaryKey is provided then it will check for the parent entity and use that. Otherwise it will return nil.
   - parameter entityName: The name of the Core Data entity.
   - parameter localPrimaryKey: The primary key.
   - parameter parent: The parent of the object.
   - parameter parentRelationshipName: The name of the relationship with the parent.
   - returns: A NSManagedObject contained in the provided context.
   */
  public func safeObject(_ entityName: String, localPrimaryKey: Any?, pkKey: String) -> NSManagedObject? {
    var result: NSManagedObject?
    
    if let localPrimaryKey = localPrimaryKey as? NSObject {
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
      request.predicate = NSPredicate(format: "%K = %@", pkKey, localPrimaryKey)
      do {
        let objects = try fetch(request)
        result = objects.first as? NSManagedObject
      } catch {
        fatalError("Failed to fetch request for entityName: \(entityName), predicate: \(String(describing: request.predicate))")
      }
    }
    
    return result
  }
}
