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
    return properties.compactMap({ property -> NSRelationshipDescription? in
      return property as? NSRelationshipDescription
    })
  }
  
  func attributes() -> [NSAttributeDescription] {
    return properties.compactMap({ property -> NSAttributeDescription? in
      return property as? NSAttributeDescription
    })
  }
}
