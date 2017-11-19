//
//  NSPropertyDescription+Ext.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

extension NSPropertyDescription {  
  func customKey() -> String? {
    guard let info = self.userInfo else {
      return nil
    }
    
    return info[Constant.CustomExportKey] as? String
  }
  
  func shouldExportAttribute() -> Bool {
    guard let info = self.userInfo else {
      return false
    }
    
    let nonExportableKey = info[Constant.NonExportableKey] as? String
    let shouldExportAttribute = (nonExportableKey == nil)
    return shouldExportAttribute;
  }
  
  func customTransformerName() -> String? {
    guard let info = self.userInfo else {
      return nil
    }
    
    return info[Constant.CustomValueTransformerKey] as? String
  }
}
