//
//  ViewController.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import UIKit
import DATAStack
import DBUtils

class DateToStringTransformer: ValueTransformer {
  override class func transformedValueClass() -> AnyClass { //What do I transform
    return NSDate.self
  }
  
  override class func allowsReverseTransformation() -> Bool { //Can I transform back?
    return true
  }
  
  override func transformedValue(_ value: Any?) -> Any? {
    guard let type = value as? Date else { return nil }
    let formatter = NSManagedObject.defaultDateFormatter
    return formatter.string(from: type)
  }
  
  override func reverseTransformedValue(_ value: Any?) -> Any? {
    guard let type = value as? String else { return nil }
    let formatter = NSManagedObject.defaultDateFormatter
    
    return formatter.date(from: type)
  }
}

class ViewController: UIViewController {

  let dataStack = DATAStack(modelName:"db")
  let logger = Atlantis.Logger()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let d: [  String: Any] = ["id": 5, "name": "Lotro Bregich",
                             "infos":  [["id": 4, "boolValue": false,
                       "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.34,
                       "doubleValue": 3.23421, "binaryValue": NSNull(), "decimalValue": 43.3,
                       "date": "2012-10-11T23:14:00+00:00"],
                      ["id": 2, "boolValue": true,
                       "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.123456789,
                       "doubleValue": 3.123456789, "binaryValue": NSNull(), "decimalValue": 43.123456789,
                       "date": "2012-10-11T23:14:00+00:00"]]]

    
    
    dataStack.performInNewBackgroundContext { [weak self] context in
//      let obj = try! EntityMapper<InfoEntity>(context: context, object: d).mapSelf()
      ValueTransformer.setValueTransformer(DateToStringTransformer(), forName: NSValueTransformerName(rawValue: "DateToStringTransformer"))
      let mapper = EntityMapper<AbilityEntity>(context: context)
      _ = try! mapper.mapSelf(object: d)
      
      try! context.save()
      self?.log()
    }
  }
  
  func tetst() {
    let pred = NSPredicate(value: true)
    let s: [AbilityEntity]? = objects(type: AbilityEntity.self, predicate: pred, sort: [NSSortDescriptor(key: "id", ascending: true)])
    
    var pppp = [String: Any]()
    if let ss = s {
      for p in ss {
        pppp = p.toJSON()
      }
    }
    
    dataStack.performInNewBackgroundContext { [weak self] context in
      
      
      
      let mapper = EntityMapper<AbilityEntity>(context: context)
      let obj = try! mapper.mapSelf(object: pppp)
      
      try! context.save()
      self?.log()
    }
  }
  
  func log() {
    let pred = NSPredicate(value: true)
    let s: [AbilityEntity]? = objects(type: AbilityEntity.self, predicate: pred, sort: [NSSortDescriptor(key: "id", ascending: true)])
    
    if let ss = s {
      for p in ss {
        logger.debug(p.toJSON())
      }
    }
  }

  func objects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate, sort: [NSSortDescriptor]?) -> [T]? {
    do {
      let entityName = String(describing: type.self)
      let fetchRequest : NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = predicate
      
      if let descriptors = sort {
        fetchRequest.sortDescriptors = descriptors
      }
      
      return try self.dataStack.mainContext.fetch(fetchRequest)
    } catch {
      return nil
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

