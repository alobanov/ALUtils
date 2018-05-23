//
//  InfoEntity+Additions.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import CoreData
import Foundation

extension InfoEntity: NSManagedObjectMappable, NSManagedObjectExportable {
  public struct Fields {
    static let id = "id"
    static let binaryValue = "binaryValue"
    static let boolValue = "boolValue"
    static let date = "date"
    static let dateValue = "dateValue"
    static let decimalValue = "decimalValue"
    static let doubleValue = "doubleValue"
    static let floatValue = "floatValue"
  }

  public struct Relations {
    static let ability = "ability"
    static let ability1 = "ability1"
  }

  public static func primaryKey() -> String {
    return Fields.id
  }

  public static func keysSubstitution() -> [(local: String, remote: String)] {
    return [(Fields.doubleValue, "double_value")]
  }

  public func map(from object: [String: Any]) throws {
    do {
      let mapper = EntityMapper(mo: self, json: object)
      try mapper.mapProperties()
      //      try mapper.mapRelationToOne(name: Relations.standEvent, type: StandEventData.self, deletionRule: .delete)

    } catch let e {
      throw e as NSError
    }
  }
}

// @objc(InfoEntity)
// public class InfoEntity: NSManagedObject, NSManagedObjectMappable {
//  public struct Fields {
//    static let id = "id"
//  }
//
//  public struct Relations {
//
//  }
//
//  public static func primaryKey() -> String {
//    return "id"
//  }
//
//  public func map(object: [String: Any], context: NSManagedObjectContext) {
//
//    self.id = Int64(object.int(by: "id") ?? 0)
//    self.boolValue = object.bool(by: "boolValue") ?? false
//
//    self.dateValue = object.date(by: "dateValue", dateFormat: nil, gmt: false)
//
//    self.date = object.string(by: "date")
//    self.floatValue = object.float(by: "floatValue") ?? 0
//    self.doubleValue = object.double(by: "double_value") ?? 0
//    self.binaryValue = object.data(by: "binaryValue")
//    self.decimalValue = object.decimal(by: "decimalValue")
//  }
// }
