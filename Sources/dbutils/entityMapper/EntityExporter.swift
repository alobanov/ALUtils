//
//  EntityExporter.swift
//  InopromSB
//
//  Created by nvv on 11/05/2018.
//  Copyright © 2018 SML. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

public protocol NSManagedObjectExportable {
  static func nonExportableKeys() -> [String]
  static func keysSubstitution() -> [(local: String, remote: String)]
  static func exportTransformers() -> [(property: String, transformer: String)]
}

public extension NSManagedObjectExportable {
  public static func nonExportableKeys() -> [String] {
    return []
  }
  public static func exportTransformers() -> [(property: String, transformer: String)] {
    return []
  }
}

public class EntityExporter {
  
  public enum InflectionType: Int {
    case snakeCase = 0
    case camelCase
  }
  
  public var dateFormatter: (DateFormatter) = {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale?
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
  }()
  
  public func toJSON(_ mo: NSManagedObject & NSManagedObjectExportable) -> [String: Any] {
    return toJSON(mo, parent: nil, inflectionType: .camelCase)
  }

  private func toJSON(_ mo: NSManagedObject & NSManagedObjectExportable,
                      parent: NSManagedObject?,
                      inflectionType: InflectionType) -> [String: Any]
  {
    var json = Dictionary<String, Any>()
    let moType = type(of: mo)
    let keysSubstitutions = moType.keysSubstitution()
    let nonExportableKeys = moType.nonExportableKeys()
    for propertyDescription in mo.entity.properties {
      let localkey = propertyDescription.name
      if nonExportableKeys.index(of: localkey) != nil {
        continue
      }
      let exportKey = self.exportKey(for: localkey, substitutions: keysSubstitutions, inflectionType: inflectionType)
      if let attributeDescription = propertyDescription as? NSAttributeDescription {
        let value = self.value(attributeDescription: attributeDescription, in: mo)
        json[exportKey] = value;
      } else if let relationshipDescription = propertyDescription as? NSRelationshipDescription {
        let isValidRelationship = !(parent != nil && parent?.entity == relationshipDescription.destinationEntity && !relationshipDescription.isToMany)
        guard isValidRelationship else {
          continue
        }
        guard let relationship = mo.value(forKey: localkey) else {
          continue
        }
        if let toOne = relationship as? (NSManagedObject & NSManagedObjectExportable) { // to one
          let attributesForToOneRelationship = self.attributesForToOne(relationship: toOne, relationshipName: exportKey, parent: mo, inflectionType: inflectionType)
          json.merge(with: attributesForToOneRelationship)
        } else if let toMany = relationship as? NSSet { // to many
          let attributesForToManyRelationship = self.attributesForToMany(relationships: toMany, relationshipName: exportKey, parent: mo, inflectionType: inflectionType)
          json.merge(with: attributesForToManyRelationship)
        }
      }
    }
    return json
  }
  
  func attributesForToOne(relationship: NSManagedObject & NSManagedObjectExportable,
                          relationshipName:String,
                          parent: NSManagedObject,
                          inflectionType: InflectionType) -> [String: Any]
  {
    var attributesForToOneRelationship = [String: Any]()
    let attributes = self.toJSON(relationship, parent: parent,inflectionType: inflectionType)
    if (attributes.count > 0) {
      var key: String = ""
      switch (inflectionType) {
      case .snakeCase:
        key = relationshipName.toSnakeCase()
      case .camelCase:
        key = relationshipName
      }
      attributesForToOneRelationship[key] = attributes
    }
    return attributesForToOneRelationship;
  }
  
  func attributesForToMany(relationships: NSSet,
                           relationshipName: String,
                           parent: NSManagedObject,
                           inflectionType: InflectionType) -> [String: Any]
  {
    var attributesForToManyRelationship = [String: Any]()
    var relationsArray = [[String: Any]]()
    for relationship in relationships {
      var attributes = [String: Any]()
      if let r = relationship as? (NSManagedObject & NSManagedObjectExportable) {
        attributes = self.toJSON(r, parent: parent, inflectionType: inflectionType)
      }
      if attributes.count > 0 {
        relationsArray.append(attributes)
      }
    }
    var key = ""
    switch (inflectionType) {
    case .snakeCase:
      key = relationshipName.toSnakeCase()
    case .camelCase:
      key = relationshipName
    }
    attributesForToManyRelationship[key] = relationsArray
    return attributesForToManyRelationship;
  }
  
  func value(attributeDescription:NSAttributeDescription,
             in mo: NSManagedObject & NSManagedObjectExportable) -> Any
  {
    var value: Any?
    let moType = type(of: mo)
    let exportTransformers = moType.exportTransformers()
    if attributeDescription.attributeType != NSAttributeType.transformableAttributeType {
      value = mo.value(forKey: attributeDescription.name)
      let nilOrNullValue = (value == nil || value is NSNull)
      let transformerName = exportTransformers.index { $0.property == attributeDescription.name }.map { return exportTransformers[$0].transformer }
      if (nilOrNullValue) {
        value = NSNull()
      } else if let transformerName = transformerName {
        let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: transformerName))
        if transformer != nil, let v = value {
          value = transformer?.transformedValue(v)
        }
      } else if let date = value as? NSDate {
        value = dateFormatter.string(from: date as Date)
      }
    }
    return value ?? NSNull()
  }
  
  func exportKey(for localKey: String, substitutions: [(local: String, remote: String)], inflectionType: InflectionType) -> String
  {
    var remoteKey = localKey
    let substitution = substitutions.index { (local, remote) -> Bool in
      return local == localKey
    }.map({ substitutions[$0].remote })
    if let substitution = substitution {
      remoteKey = substitution
    } else {
      switch inflectionType {
      case .snakeCase:
        remoteKey = remoteKey.toSnakeCase()
      case .camelCase:
        //already in camel case ???
        break
      }
    }
    return remoteKey
  }
  
}
