//
//  NSPropertyDescription+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

public extension NSRelationshipDescription {
  public func relationCustomKey() -> String? {
    guard let info = self.userInfo else {
      return nil
    }
    
    return info[Constant.CustomExportKey] as? String
  }
}

public extension NSPropertyDescription {  
  public func customKey() -> String? {
    guard let info = self.userInfo else {
      return nil
    }
    
    return info[Constant.CustomExportKey] as? String
  }
  
  public func shouldExportAttribute() -> Bool {
    guard let info = self.userInfo else {
      return false
    }
    
    let nonExportableKey = info[Constant.NonExportableKey] as? String
    let shouldExportAttribute = (nonExportableKey == nil)
    return shouldExportAttribute;
  }
  
  public func customTransformerName() -> String? {
    guard let info = self.userInfo else {
      return nil
    }
    
    return info[Constant.CustomValueTransformerKey] as? String
  }
}
