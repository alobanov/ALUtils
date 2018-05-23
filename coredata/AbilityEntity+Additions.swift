//
//  AbilityEntity+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import CoreData
import Foundation
// import DBUtils

extension AbilityEntity: NSManagedObjectMappable, NSManagedObjectExportable {
  public struct Fields {
    static let id = "id"
    static let name = "name"
  }

  public struct Relations {
    static let infoItem = "infoItem"
    static let infoItems = "infoItems"
  }

  public static func primaryKey() -> String {
    return Fields.id
  }

  public static func keysSubstitution() -> [(local: String, remote: String)] {
    return [(Relations.infoItems, "info_items")]
  }

  public func map(from object: [String: Any]) throws {
    do {
      let mapper = EntityMapper(mo: self, json: object)
      try mapper.mapProperties()
      try mapper.mapRelationToOne(name: Relations.infoItem, type: InfoEntity.self)
      try mapper.mapRelationToMany(name: Relations.infoItems, type: InfoEntity.self)
    } catch let e {
      throw e as NSError
    }
  }
}

//
// @objc(AbilityEntity)
// public class AbilityEntity: NSManagedObject, NSManagedObjectMappable {
//  public struct Fields {
//    static let id = "id"
//    static let name = "name"
//  }
//
//  public struct Relations {
//    static let infos = "infoItems"
//  }
//
//  public static func primaryKey() -> String {
//    return "id"
//  }
//
//  public func map(object: [String: Any], context: NSManagedObjectContext) throws {
//    do {
//      self.id = Int64(object.int(by: Fields.id) ?? 0)
//      self.name = object.string(by: Fields.name) ?? ""
//
//      let mapper = EntityMapper<AbilityEntity>(context: context)
//      if let infos = try mapper.mapRelationToMany(relation: Relations.infos, type: InfoEntity.self, object: object) {
//        self.infoItems = NSSet(array: infos)
//      } else {
//        self.infoItems = nil
//      }
//
//      if let info = try mapper.mapRelationToOne(relation: "iii", type: InfoEntity.self, object: object) {
//        self.iii = info
//      } else {
//        self.iii = nil
//      }
//
//    } catch (let e) {
//      throw e as NSError
//    }
//  }
// }
