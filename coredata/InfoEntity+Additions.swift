//
//  InfoEntity+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData
//import DBUtils

@objc(InfoEntity)
public class InfoEntity: NSManagedObject, NSManagedObjectMappable {
  public struct Fields {
    static let id = "id"
  }
  
  public struct Relations {
    
  }
  
  public static func primaryKey() -> String {
    return "id"
  }
  
  public func map(object: [String: Any], context: NSManagedObjectContext) {
    let formatter = NSManagedObject.defaultDateFormatter
    self.id = Int64(object.int(by: "id") ?? 0)
    self.boolValue = object.bool(by: "boolValue") ?? false
    
    if let strDate = object.string(by: "dateValue") {
      self.dateValue = formatter.date(from: strDate)
    }
    
    self.date = object.string(by: "date")
    self.floatValue = object.float(by: "floatValue") ?? 0
    self.doubleValue = object.double(by: "double_value") ?? 0
    self.binaryValue = object.data(by: "binaryValue")
    self.decimalValue = object.decimal(by: "decimalValue")
  }
}
