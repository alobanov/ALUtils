//
//  ViewController.swift
//  EntitySerialization
//
//  Created by Lobanov Aleksey on 17/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import UIKit
import DATAStack
import RxSwift
//import DBUtils

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
  let provider = CoredataProvider(dataStack: DATAStack(modelName:"db"))
  let logger = Atlantis.Logger()
  let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let d: [[String: Any]] = [
      ["id": 5, "name": "Lotro Bregich",
       "iii": ["id": 4, "boolValue": false,
               "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.34,
               "double_value": 3.23421, "binaryValue": NSNull(), "decimalValue": 43.3,
               "date": "2012-10-11T23:14:00+00:00"],
                             "info_items":
                                [["id": 2, "boolValue": false,
                                  "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.34,
                                  "double_value": 3.23421, "binaryValue": NSNull(), "decimalValue": 43.3,
                                  "date": "2012-10-11T23:14:00+00:00"],
                                 ["id": 2, "boolValue": true,
                                  "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.123456789,
                                  "double_value": 3.123456789, "binaryValue": NSNull(), "decimalValue": 43.123456789,
                                  "date": "2012-10-11T23:14:00+00:00"]]],
      ["id": 4, "name": "Lotro Bregich",
       "iii": ["id": 4, "boolValue": false,
               "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.34,
               "double_value": 3.23421, "binaryValue": NSNull(), "decimalValue": 43.3,
               "date": "2012-10-11T23:14:00+00:00"],
       "info_items":
        [["id": 1, "boolValue": false,
          "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.34,
          "double_value": 3.23421, "binaryValue": NSNull(), "decimalValue": 43.3,
          "date": "2012-10-11T23:14:00+00:00"],
         ["id": 2, "boolValue": true,
          "dateValue": "2012-10-11T23:14:00+05:00", "floatValue": 3.123456789,
          "double_value": 3.123456789, "binaryValue": NSNull(), "decimalValue": 43.123456789,
          "date": "2012-10-11T23:14:00+00:00"]]]]

    
    
    provider.mapArray(AbilityEntity.self, jsonArray: d).subscribe(onNext: { _ in
      print("Success save")
//      self.delete()
      self.log()
    }, onError: { error in
      print(error.localizedDescription)
    }).disposed(by: bag)
    
    provider.edit { context -> Observable<Void> in
        do {
          let objects: [AbilityEntity] = try NSManagedObject.createOrUpdateEntities(context: context, pkKey: "id", id: 5)
          
          for entity in objects {
            entity.name = "asdasdasdasdasdadad"
          }
          
          return Observable.just()
        } catch (let e) {
          return Observable.error(e)
        }
      }.subscribe(onNext: { _ in
        print("success")
      }, onError: { error in
        print("error")
      }).disposed(by: bag)
    
//    dataStack.performInNewBackgroundContext { [weak self] context in
////      let obj = try! EntityMapper<InfoEntity>(context: context, object: d).mapSelf()
//      ValueTransformer.setValueTransformer(DateToStringTransformer(), forName: NSValueTransformerName(rawValue: "DateToStringTransformer"))
//      let mapper = EntityMapper<AbilityEntity>(context: context)
//      _ = try! mapper.mapSelf(object: d)
//
//      try! context.save()
//      self?.log()
//    }
  }
  
  func delete() {
    provider.delete(InfoEntity.self, id: 4, primaryKey: "id").subscribe(onNext: { _ in
      print("Success delete")
      self.log()
    }).disposed(by: bag)
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

