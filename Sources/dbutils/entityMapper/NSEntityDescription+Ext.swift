//
//  NSEntityDescription+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

extension NSEntityDescription {
  func relationships() -> [NSRelationshipDescription] {
    var relationships = [NSRelationshipDescription]()
    for propertyDescription in properties {
      if let relationshipDescription = propertyDescription as? NSRelationshipDescription {
        relationships.append(relationshipDescription)
      }
    }
    
    return relationships
  }
  
  func attributes() -> [NSAttributeDescription] {
    var attributes = [NSAttributeDescription]()
    for propertyDescription in properties {
      if let attributeDescription = propertyDescription as? NSAttributeDescription {
        attributes.append(attributeDescription)
      }
    }
    
    return attributes
  }
}
