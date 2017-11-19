//
//  NSManagedObject+Serialization.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import CoreData

public enum MapperRelationshipType: Int {
  case none = 0
  case array
  case nested
};

public enum MapperInflectionType: Int {
  case snakeCase = 0
  case camelCase
}

public struct Constant {
  static let CompatiblePrimaryKey = "remoteID"
  static let RemotePrimaryKey = "id"
  static let NestedAttributesKey = "attributes"
  static let CustomExportKey = "exportKey"
  static let NonExportableKey = "export"
  static let CustomValueTransformerKey = "exportTransformer"
}

public extension NSManagedObject {
  func remotePrefixUsing(inflectionType: MapperInflectionType) -> String {
    switch (inflectionType) {
    case .snakeCase:
      return "\(self.entity.name?.toSnakeCase() ?? "")_"
    case .camelCase:
      return self.entity.name ?? ""
    }
  }
  
  func attributesForToOne(relationship: NSManagedObject,
                          relationshipName:String,
                          relationshipType: MapperRelationshipType,
                          parent: NSManagedObject,
                          dateFormatter: DateFormatter,
                          inflectionType: MapperInflectionType) -> [String: Any] {
    var attributesForToOneRelationship = [String: Any]()
    let attributes = relationship.toJSON(parent: parent,
                                         dateFormatter: dateFormatter,
                                         inflectionType: inflectionType,
                                         relationshipType: relationshipType)
    if (attributes.count > 0) {
      var key: String = ""
      switch (inflectionType) {
      case .snakeCase:
        key = relationshipName.toSnakeCase()
        
      case .camelCase:
        key = relationshipName
      }
      if (relationshipType == .nested) {
        switch (inflectionType) {
        case .snakeCase:
          key = "\(key)_\(Constant.NestedAttributesKey)"
          break;
        case .camelCase:
          key = "\(key)\(Constant.NestedAttributesKey.capitalized)"
          break;
        }
      }
      
      attributesForToOneRelationship[key] = attributes
    }
    
    return attributesForToOneRelationship;
  }
  
  func reservedKeys(using inflectionType: MapperInflectionType) -> [String] {
    var keys: [String] = []
    
    for attribute in NSManagedObject.reservedAttributes() {
      keys.append(self.prefixedAttribute(attribute: attribute, inflectionType: inflectionType))
    }
    
    return keys
  }
  
  func remoteKey(attributeDescription: NSAttributeDescription,
                 relationshipType: MapperRelationshipType,
                 inflectionType: MapperInflectionType) -> String {
    let localKey = attributeDescription.name
    var remoteKey: String?
    
    let customRemoteKey = attributeDescription.customKey()
    if let crk = customRemoteKey {
      remoteKey = crk
    } else if localKey == Constant.RemotePrimaryKey || localKey == Constant.CompatiblePrimaryKey {
      remoteKey = Constant.RemotePrimaryKey
    } else {
      switch inflectionType {
      case .snakeCase:
        remoteKey = localKey.toSnakeCase()
        
      case .camelCase:
        remoteKey = localKey
      }
    }
    
    let isReservedKey = self.reservedKeys(using: inflectionType).contains(remoteKey ?? "")
    if (isReservedKey) {
      var prefixedKey = remoteKey ?? ""
      
      let start = prefixedKey.index(prefixedKey.startIndex, offsetBy: 0)
      let end = prefixedKey.index(prefixedKey.endIndex, offsetBy: 0)
      let myRange = start..<end
      
      prefixedKey = prefixedKey.replacingOccurrences(of: self.remotePrefixUsing(inflectionType: inflectionType), with: "", options: String.CompareOptions.caseInsensitive, range: myRange)
      remoteKey = prefixedKey
//      if (inflectionType == .camelCase) {
//        remoteKey = remoteKey
//      }
    }
    
    return remoteKey ?? ""
  }
  
  func valueFor(attributeDescription :NSAttributeDescription,
                dateFormatter: DateFormatter,
                relationshipType: MapperRelationshipType) -> Any {
    var value: Any?
    
    if attributeDescription.attributeType != NSAttributeType.transformableAttributeType {
      value = self.value(forKey: attributeDescription.name)
      let nilOrNullValue = (value == nil || value is NSNull)
      let customTransformerName: String? = attributeDescription.customTransformerName()
      if (nilOrNullValue) {
        value = NSNull()
      } else if let date = value as? NSDate {
        value = dateFormatter.string(from: date as Date)
      } else if let custom = customTransformerName {
        let transformer = ValueTransformer(forName: NSValueTransformerName(rawValue: custom))
        if transformer != nil, let v = value {
          value = transformer?.transformedValue(v)
        }
      }
    }
    
    return value ?? NSNull()
  }
  
  
  func attributesForToMany(relationships: NSSet,
                           relationshipName: String,
                           relationshipType: MapperRelationshipType,
                           parent: NSManagedObject,
                           dateFormatter: DateFormatter,
                           inflectionType: MapperInflectionType) -> [String: Any] {
    
    var attributesForToManyRelationship = [String: Any]()
    var relationIndex = 0;
    var relationsDictionary = [String: Any]()
    var relationsArray = [[String: Any]]()
    for relationship in relationships {
      var attributes = [String: Any]()
      if let r = relationship as? NSManagedObject {
        attributes = r.toJSON(parent: parent, dateFormatter: dateFormatter, inflectionType: inflectionType, relationshipType: relationshipType)
      }
      if attributes.count > 0 {
        if (relationshipType == .array) {
          relationsArray.append(attributes)
        } else if (relationshipType == .nested) {
          let relationIndexString = String(relationIndex)
          relationsDictionary[relationIndexString] = attributes
          relationIndex+=1
        }
      }
    }
    
    var key = ""
    switch (inflectionType) {
    case .snakeCase:
      key = relationshipName.toSnakeCase()
    case .camelCase:
      key = relationshipName
    }
    if (relationshipType == .array) {
      attributesForToManyRelationship[key] = relationsArray
    } else if (relationshipType == .nested) {
      let nestedAttributesPrefix = "\(key)_\(Constant.NestedAttributesKey)"
      attributesForToManyRelationship[nestedAttributesPrefix] = relationsDictionary
    }
    
    return attributesForToManyRelationship;
  }
  
  func toJSON() -> [String: Any] {
    return self.toJSON(parent: nil,
                       dateFormatter: NSManagedObject.defaultDateFormatter,
                       inflectionType: .camelCase,
                       relationshipType: .array)
  }
  
  func toJSON(parent: NSManagedObject?,
              dateFormatter: DateFormatter,
              inflectionType: MapperInflectionType,
              relationshipType: MapperRelationshipType) -> [String: Any] {
    var managedObjectAttributes = Dictionary<String, Any>()
    
    for propertyDescription in self.entity.properties {
      if let pd = propertyDescription as? NSAttributeDescription {
        if pd.shouldExportAttribute() {
          let value = self.valueFor(attributeDescription: pd,
                                    dateFormatter: dateFormatter,
                                    relationshipType: relationshipType)
          
          let remoteKey = self.remoteKey(attributeDescription: pd,
                                         relationshipType: relationshipType,
                                         inflectionType: inflectionType)
          managedObjectAttributes[remoteKey] = value;
        }
      } else if (propertyDescription is NSRelationshipDescription && relationshipType != .none) {
        let relationshipDescription = propertyDescription as! NSRelationshipDescription
        if relationshipDescription.shouldExportAttribute() {
          let isValidRelationship = !(parent != nil && parent?.entity == relationshipDescription.destinationEntity && !relationshipDescription.isToMany)
          if (isValidRelationship) {
            let relationshipName = relationshipDescription.name
            let relationships = self.value(forKey: relationshipName)
            if let rlship = relationships {
              let isToOneRelationship = (!(relationships is NSSet) && !(relationships is NSOrderedSet))
              
              let rn = relationshipDescription.relationCustomKey() ?? relationshipDescription.name
              
              if (isToOneRelationship) {
                let attributesForToOneRelationship = self.attributesForToOne(relationship: rlship as! NSManagedObject, relationshipName: rn, relationshipType: relationshipType, parent: self, dateFormatter: dateFormatter, inflectionType: inflectionType)
                managedObjectAttributes.merge(with: attributesForToOneRelationship)
              } else {
                let attributesForToManyRelationship = self.attributesForToMany(relationships: rlship as! NSSet, relationshipName: rn, relationshipType: relationshipType, parent: self, dateFormatter: dateFormatter, inflectionType: inflectionType)
                managedObjectAttributes.merge(with: attributesForToManyRelationship)
              }
            }
          }
        }
      }
    }
    
    return managedObjectAttributes
  }
  
  public static var defaultDateFormatter: (DateFormatter) = {
    // this gets executed once
    let _dateFormatter = DateFormatter()
    _dateFormatter.locale = Locale(identifier: "ru")
    _dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    return _dateFormatter;
    //But no access to instance variables...
  }()
  
  func prefixedAttribute(attribute: String, inflectionType:MapperInflectionType) -> String {
    let remotePrefix = self.remotePrefixUsing(inflectionType: inflectionType)
    
    switch (inflectionType) {
    case .snakeCase:
      return "\(remotePrefix)\(attribute)"
    
    case .camelCase:
      return "\(remotePrefix)\(attribute.capitalized)"
    }
  }
  
  class func reservedAttributes() -> [String] {
    return ["type", "description", "signed"]
  }
}
