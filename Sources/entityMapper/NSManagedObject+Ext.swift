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
  static func createOrUpdateEntities<ResultType: NSManagedObject>(context: NSManagedObjectContext, pkKey: String, pkValue: NSObject?) -> [ResultType] {
    let entityName = String(describing: ResultType.self)
    
    guard let id = pkValue else {
      fatalError("Couldn't find primary key \(pkKey) in JSON for object in entity \(entityName)")
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
