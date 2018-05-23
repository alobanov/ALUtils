//
//  NSManagedObject+Additions.swift
//  DatabaseSyncRx
//
//  Created by Lobanov Aleksey on 17/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

//TODO: возможность указывать форматтер для любого проперти

public protocol NSManagedObjectMappable {
  static func primaryKey() -> String
  static func keysSubstitution() -> [(local: String, remote: String)]
  func map(from json: [String: Any]) throws
}

public extension NSManagedObjectMappable {
  public static func keysSubstitution() -> [(local: String, remote: String)] {
    return []
  }
}

public class EntityMapper {
  
  public enum DeletionRule {
    case doNotDelete
    case delete
    case deleteifNull
  }
  
  public enum Inflection {
    case none
    case snakeCase
  }
  
  public var dateFormatter: (DateFormatter) = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
  }()
  
  private var json: JSON = JSON()
  private var mo: NSManagedObject & NSManagedObjectMappable
  private let remoteInflectionType: Inflection
  
  public init(mo: NSManagedObject & NSManagedObjectMappable, json: [String: Any], remoteInflectionType: Inflection = .none) {
    self.mo = mo
    self.remoteInflectionType = remoteInflectionType
    fixJSON(original: json)
  }
  
  // MARK: - Map properties
  public func mapProperties(deletionRule: DeletionRule = .delete) throws {
    let entityName = mo.entity.name ?? ""
    guard let context = mo.managedObjectContext else {
      throw NSError.define(description: "Managed object have no context.")
    }
    guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
      throw NSError.define(description: "Wrong entity type")
    }
    let attributes = entity.attributes()
    for attribute in attributes {
      let name = attribute.name
      let value = convertValue(name, to: attribute.attributeType)
      if value == nil {
        switch deletionRule {
          case .delete:
            mo.setValue(nil, forKey: attribute.name)
          case .deleteifNull:
            if json[name].null != nil {
              mo.setValue(nil, forKey: attribute.name)
            }
          default: break
        }
        continue
      }
      mo.setValue(value, forKey: name)
    }
  }
  
  // MARK: - Map relations
  public func mapRelationToOne<RelationType: NSManagedObjectMappable>(name: String, type: RelationType.Type, deletionRule: DeletionRule = .delete) throws {
    guard let context = mo.managedObjectContext else {
      throw NSError.define(description: "Managed object have no context.")
    }
    guard relation(name: name) != nil else {
      throw NSError.define(description: "\(mo.entity.name ?? "") doesn't have relation \(name)")
    }
    guard let relationObj = json[name].dictionaryObject else {
      if let rawJSON = json.dictionaryObject, let relationJSON = rawJSON[name], relationJSON as? [String: Any] == nil {
        throw NSError.define(description: "Relation source is not a dictionary")
      }
      switch deletionRule {
      case .delete:
        mo.setValue(nil, forKey: name)
      case .deleteifNull:
        if json[name].null != nil {
          mo.setValue(nil, forKey: name)
        }
      default: break
      }
      mo.setValue(nil, forKey: name)
      return
    }
    do {
      let result = try context.mapObject(type: RelationType.self, from: relationObj)
      mo.setValue(result, forKey: name)
    } catch (let e) {
      throw e as NSError
    }
  }
  
  public func mapRelationToMany<RelationType: NSManagedObjectMappable> (name: String, type: RelationType.Type, deletionRule: DeletionRule = .delete) throws {
    guard let context = mo.managedObjectContext else {
      throw NSError.define(description: "Managed object have no context.")
    }
    guard relation(name: name) != nil else {
      throw NSError.define(description: "\(mo.entity.name ?? "") doesn't have relation \(name)")
    }
    guard let relationArr = json[name].arrayObject as? [[String: Any]] else {
      if let rawJSON = json.dictionaryObject, let relationJSON = rawJSON[name], relationJSON as? [[String: Any]]  == nil {
        throw NSError.define(description: "Relation source is not an array of dictionaries")
      }
      switch deletionRule {
      case .delete:
        mo.setValue(nil, forKey: name)
      case .deleteifNull:
        if json[name].null != nil {
          mo.setValue(nil, forKey: name)
        }
      default: break
      }
      mo.setValue(nil, forKey: name)
      return
    }
    do {
        let result = try context.mapArray(type: RelationType.self, from: relationArr)
        mo.setValue(NSSet(array: result), forKey: name)
    } catch (let e) {
      throw e as NSError
    }
  }
  
  // MARK: - Private
  
  private func fixJSON(original: [String: Any]) {
    let remoteKeyReplacement = type(of: mo).keysSubstitution()
    var fixedJSON = replaceKeys(remoteKeyReplacement, in: original)
    let fixedKeys = remoteKeyReplacement.map { $0.local }
    let keys = fixedJSON.keys.filter { !fixedKeys.contains($0) }
    if remoteInflectionType != .none {
      for key in keys {
        if fixedKeys.contains(key) {
          continue
        }
        let value = fixedJSON[key]
        fixedJSON[key] = nil
        let infectedKey = inflectToCamelCase(key: key, type: remoteInflectionType)
        fixedJSON[infectedKey] = value
      }
    }
    self.json = JSON(fixedJSON)
  }
  
  private func inflectToCamelCase(key: String, type: Inflection) -> String {
    var inflectedkey = key
    switch type {
    case .snakeCase:
      inflectedkey = key.split(separator: "_").reduce("") {(acc, name) in
        "\(acc)\(acc.count > 0 ? String(name.capitalized) : String(name))"
      }
    default: break
    }
    return inflectedkey
  }
  
  private func replaceKeys(_ keys: [(String, String)], in object: [String: Any]) -> [String: Any] {
    var object = object
    for (local, remote) in keys {
      if let value = object[remote] {
        object[remote] = nil
        object[local] = value
      }
    }
    return object
  }
  
  private func convertValue(_ name: String, to type: NSAttributeType) -> Any? {
    var value: Any?
    switch type {
    case .integer16AttributeType:
      value = json[name].int
    case .integer32AttributeType:
      value = json[name].int32
    case .integer64AttributeType:
      value = json[name].int64
    case .stringAttributeType:
      value = json[name].string
    case .booleanAttributeType:
      value = json[name].bool
    case .decimalAttributeType:
      value = json[name].number
    case .floatAttributeType:
      value = json[name].float
    case .doubleAttributeType:
      value = json[name].double
    case .dateAttributeType:
      if let dateStr = json[name].string,
        let date = dateFormatter.date(from: dateStr)
      {
        value = date
      }
    default: break
    }
    return value
  }

  private func relation(name: String) -> NSRelationshipDescription? {
    guard let relationDescription = mo.entity.relationships().compactMap({ item -> NSRelationshipDescription? in
        return item.name == name ? item : nil
      }).first
      else {
        return nil
    }
    return relationDescription
  }

}
