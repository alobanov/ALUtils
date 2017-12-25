//
//  SyncSaveOperations.swift
//  Puls
//
//  Created by Lobanov Aleksey on 28/09/2017.
//  Copyright © 2017 MOPC. All rights reserved.
//

import Foundation
import DATAStack
import RxSwift

public class SaveArrayOperation<T: NSManagedObjectMappable>: AsyncOperation {
  private typealias ManageObject = T
  private let json: JSONArrayDictionary
  private let dataStack: DATAStack
  
  public init(jsonArray: JSONArrayDictionary, dataStack: DATAStack) {
    self.json = jsonArray
    self.dataStack = dataStack
    super.init()
  }
  
  public override func main() {
    save()
  }
  
  public func save() {
    self.dataStack.performBackgroundTask { [weak self] context in
      let mapper = EntityMapper<T>(context: context)
      do {
        try mapper.mapArray(objects: self?.json ?? [])
        
        if let block = self?.completion {
          do {
            try context.save()
            block(nil)
          } catch let saveError {
            block(saveError as NSError)
          }
        }
        self?.cancel()
      } catch (let e) {
        if let block = self?.completion {
          block(e as NSError)
        }
        self?.cancel()
      }
    }
  }
}

public class EditOperation: AsyncOperation {
  
  public typealias ActionClosure = (_ context: NSManagedObjectContext) -> Observable<Void>
  
  public let action: ActionClosure
  private let dataStack: DATAStack
  
  private let bag = DisposeBag()
  
  public init(action: @escaping ActionClosure, dataStack: DATAStack) {
    self.action = action
    self.dataStack = dataStack
    super.init()
  }
  
  public override func main() {
    run()
  }
  
  public func run() {
    dataStack.performBackgroundTask { [weak self] context in
      guard let sSelf = self else {
        return
      }
      sSelf.action(context).subscribe(onNext: { [weak self] in
        guard let sSelf = self else {
          return
        }
        if let block = sSelf.completion {
          do {
            try context.save()
            block(nil)
          } catch let saveError {
            block(saveError as NSError)
          }
        }
        
        sSelf.cancel()
      }, onError: {[weak self] error in
        guard let sSelf = self else {
          return
        }
        if let block = sSelf.completion {
          block(error as NSError)
        }
        
        sSelf.cancel()
      }).disposed(by: sSelf.bag)
    }
  }
}

public class DeleteArrayOperation<T: NSManagedObject>: AsyncOperation {
  private typealias ManageObject = T
  private let dataStack: DATAStack
  private let primaryKey: String
  private let ids: [Any]
  
  public init(ids:[Any], primaryKey: String, dataStack: DATAStack) {
    self.ids = ids
    self.dataStack = dataStack
    self.primaryKey = primaryKey
    super.init()
  }
  
  public override func main() {
    run()
  }
  
  public func run() {
    dataStack.performInNewBackgroundContext({ [weak self]  context in
      guard let sSelf = self else {
        return
      }
      do {
        let entityName = String(describing: ManageObject.self)
        for id in sSelf.ids {
          try NSManagedObject.delete(id, primaryKey: self?.primaryKey ?? "", inEntityNamed: entityName, using: context)
        }
        if let block = sSelf.completion {
          do {
            try context.save()
            block(nil)
          } catch let saveError {
            block(saveError as NSError)
          }
        }
        sSelf.cancel()
      } catch let(err) {
        if let block = sSelf.completion {
          block(err as NSError)
        }
        sSelf.cancel()
      }
    })
  }
}
