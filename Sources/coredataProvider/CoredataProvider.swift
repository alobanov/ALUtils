//
//  CoredataQueryProvider.swift
//  ALUtils
//
//  Created by Lobanov Aleksey on 19/08/2017.
//  Copyright © 2017 ALUtils. All rights reserved.
//

import CoreData
import RxSwift
import DATAStack
import ObjectMapper

enum ORMError {
  case notDefineDATAStack
  case failedParsingJson(objectTypeStr: String)
  case failedSavedObjectNotFoundInDB(objectTypeStr: String)
  case failedMapObject(objectTypeStr: String)
  
  var error: NSError {
    switch self {
    case .notDefineDATAStack:
      return NSError.define(description: "DataStack not define.",
                            failureReason: "Bad news, something wrong with DATAStack in CoredataProvider",
                            code: -31)
    case .failedParsingJson(let objectTypeStr):
      return NSError.define(description: "Can`t parse json object ot "+objectTypeStr+" class type.",
                            failureReason: "Check your "+objectTypeStr+" class mapper rules.",
                            code: -32)
    case .failedSavedObjectNotFoundInDB(let objectTypeStr):
      return NSError.define(description: "Can`t find object "+objectTypeStr+" class type, after saving in DB.",
                            failureReason: "Check your "+objectTypeStr+" class mapper rules.",
                            code: -33)
    case .failedMapObject(let objectTypeStr):
      return NSError.define(description: "Can`t map object "+objectTypeStr+" class type.",
                            failureReason: "Check your "+objectTypeStr+" class mapper rules.",
                            code: -33)
    }
  }
}

public protocol CoredataMappable {
  func mapObject<T: NSManagedObjectMappable>(_ type: T.Type, json: JSONDictionary) -> Observable<Void>
  func mapAndReturnObject<T: NSManagedObjectMappable, ReturnType: Mappable>(_ type: T.Type, returnType: ReturnType.Type, json: JSONDictionary) -> Observable<ReturnType>
  func mapArray<T: NSManagedObjectMappable>(_ type: T.Type, jsonArray: JSONArrayDictionary) -> Observable<Void>
  func mapAndReturnArray <T: NSManagedObjectMappable, ReturnType: Mappable>
  (_ type: T.Type, returnType: ReturnType.Type, jsonArray: JSONArrayDictionary) -> Observable<[ReturnType]>
  func edit(_ closure: @escaping EditOperation.ActionClosure) -> Observable<Void>
}

public protocol CoredataDeletable {
  func delete<T: NSManagedObject>(_ type: T.Type, id: Any, primaryKey: String) -> Observable<Void>
  func delete<T: NSManagedObject>(_ type: T.Type, ids: [Any], primaryKey: String) -> Observable<Void>
}

public protocol CoredataFetcher {
  func models<T: Mappable, U: NSManagedObject>(type: U.Type, predicate: NSPredicate, sortBy: String?, asc: Bool?) -> [T]?
  func firstModel<T: Mappable, U: NSManagedObject>(type: U.Type, predicate: NSPredicate) -> T?
  
  func objects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate, sortBy: String?, asc: Bool?) -> [T]?
  func firstObject<T: NSManagedObject>(type: T.Type, predicate: NSPredicate) -> T?
  
  func mainContext() -> NSManagedObjectContext
}

public protocol CoredataCleanable {
  func clean(doNotDeleteEntities:[NSManagedObject.Type]) -> Observable<Void>
}

public class CoredataProvider: CoredataMappable, CoredataFetcher, CoredataCleanable, CoredataDeletable {
  let dataStack: DATAStack
  let serialOperationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.underlyingQueue = DispatchQueue(label: "ru.lobanov.serialDatabaseQueue")
    return queue
  }()
  
  public init(dataStack: DATAStack) {
    self.dataStack = dataStack
  }
}

public extension CoredataCleanable  where Self: CoredataProvider {
  func clean(doNotDeleteEntities:[NSManagedObject.Type]) -> Observable<Void> {
    return Observable<Void>.create({ [weak self] observer -> Disposable in
      
      guard let stack = self?.dataStack else {
        observer.onError(ORMError.notDefineDATAStack.error)
        return Disposables.create()
      }
      
      var entitiesNames = [String]()
      for entity in stack.persistentStoreCoordinator.managedObjectModel.entities {
        if let name = entity.name,
          let managedObjectClass = NSClassFromString(entity.managedObjectClassName)
        {
          let contains = doNotDeleteEntities.contains(where: { type -> Bool in
            let isSubclass = managedObjectClass.isSubclass(of: type.self)
            let isSubclass2 = type.isSubclass(of: managedObjectClass.self)
            let isClass = managedObjectClass.self == type.self
            return isSubclass || isSubclass2 || isClass
          })
          if (!contains) {
            entitiesNames.append(name)
          }
        }
      }
      
      stack.performInNewBackgroundContext({ context in
        do {
          context.undoManager = nil
          for name in entitiesNames {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            request.includesPropertyValues = false
            request.includesSubentities = false
            let deleteAllRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteAllRequest)
          }
          observer.onNext(())
          observer.onCompleted()
        } catch let(err) {
          observer.onError(err)
        }
      })
      return Disposables.create()
    }).observeOn(ALSchedulers.shared.mainScheduler)
  }
  
}

public extension CoredataMappable where Self: CoredataProvider {
  func mapObject<T: NSManagedObjectMappable>(_ type: T.Type, json: JSONDictionary) -> Observable<Void> {
    return mapArray(type, jsonArray: [json])
  }

  func mapAndReturnObject<T: NSManagedObjectMappable, ReturnType: Mappable>
    (_ type: T.Type, returnType: ReturnType.Type, json: JSONDictionary) -> Observable<ReturnType> {
    return mapAndReturnArray(type, returnType: returnType, jsonArray: [json])
      .flatMap({ objects -> Observable<ReturnType> in
        if let first = objects.first {
          return Observable.just(first)
        } else {
          throw ORMError.failedSavedObjectNotFoundInDB(objectTypeStr: "\(T.self)").error
        }
      })
  }
  
  func mapAndReturnArray <T: NSManagedObjectMappable, ReturnType: Mappable>
    (_ type: T.Type, returnType: ReturnType.Type, jsonArray: JSONArrayDictionary) -> Observable<[ReturnType]>
  {
    return Observable<[ReturnType]>.create({ [weak self] observer -> Disposable in
      
      guard let stack = self?.dataStack else {
        observer.onError(ORMError.notDefineDATAStack.error)
        return Disposables.create()
      }
      
      var models: [ReturnType] = []
      let op = EditOperation(action: { context -> Observable<Void> in
        return Observable<Void>.just(())
          .map({ _ -> [T] in
            let mapper = EntityMapper<T>(context: context)
            let entities = try mapper.mapArray(objects: jsonArray)
            return entities
          })
          .do(onNext: { entities in
            try models = entities.map { entity in
              let json = entity.toJSON()
              if let model = Mapper<ReturnType>().map(JSON: json) {
                return model
              } else {
                throw ORMError.failedParsingJson(objectTypeStr: "\(ReturnType.self)").error
              }
            }
          })
          .mapToVoid()
      }, dataStack: stack)
      
      op.completion = { error in
        if let existErr = error {
          observer.onError(existErr)
        } else {
          observer.onNext(models)
          observer.onCompleted()
        }
      }
      
      self?.serialOperationQueue.addOperation(op)
      return Disposables.create()
    }).observeOn(ALSchedulers.shared.mainScheduler)
  }

  func mapArray<T: NSManagedObjectMappable>(_ type: T.Type, jsonArray: JSONArrayDictionary) -> Observable<Void> {
    return Observable<Void>.create({ [weak self] observer -> Disposable in
      
      guard let stack = self?.dataStack else {
        observer.onError(ORMError.notDefineDATAStack.error)
        return Disposables.create()
      }
      
      let op = EditOperation(action: { context -> Observable<Void> in
        return Observable<Void>.just(())
          .map({ _ -> [T] in
            let mapper = EntityMapper<T>(context: context)
            let entities = try mapper.mapArray(objects: jsonArray)
            return entities
          }).mapToVoid()
      }, dataStack: stack)
      
      op.completion = { error in
        if let existErr = error {
          observer.onError(existErr)
        } else {
          observer.onNext(())
          observer.onCompleted()
        }
      }
      
      self?.serialOperationQueue.addOperation(op)
      return Disposables.create()
    }).observeOn(ALSchedulers.shared.mainScheduler)
  }
  
  func edit(_ closure: @escaping EditOperation.ActionClosure) -> Observable<Void> {
    return Observable<Void>.create({ [weak self] observer -> Disposable in
      
      guard let stack = self?.dataStack else {
        observer.onError(ORMError.notDefineDATAStack.error)
        return Disposables.create()
      }
      
      let op = EditOperation(action: closure, dataStack: stack)
      op.completion = { error in
        if let existErr = error {
          observer.onError(existErr)
        } else {
          observer.onNext(())
          observer.onCompleted()
        }
      }
      self?.serialOperationQueue.addOperation(op)
      return Disposables.create()
    }).observeOn(ALSchedulers.shared.mainScheduler)
  }
  
}

public extension CoredataFetcher where Self: CoredataProvider {
  
  func mainContext() -> NSManagedObjectContext {
    return dataStack.mainContext
  }
  
  func models<T: Mappable, U: NSManagedObject>(type: U.Type, predicate: NSPredicate, sortBy: String?, asc: Bool?) -> [T]? {
    do {
      let entityName = String(describing: type.self)
      let fetchRequest : NSFetchRequest<U> = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = predicate
      
      if let sortField = sortBy {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortField, ascending: asc ?? true)]
      }
      
      let fetchedResults = try mainContext().fetch(fetchRequest)
      
      return fetchedResults.compactMap { model -> T? in
        let json = model.toJSON()
        if let obj: T = Mapper<T>().map(JSON: json) {
          return obj
        } else {
          return nil
        }
      }
    } catch {
      return nil
    }
  }
  
  func firstModel<T: Mappable, U: NSManagedObject>(type: U.Type, predicate: NSPredicate) -> T? {
    do {
      let entityName = String(describing: type.self)
      let fetchRequest : NSFetchRequest<U> = NSFetchRequest(entityName: entityName)
      
      fetchRequest.predicate = predicate
      let fetchedResults = try mainContext().fetch(fetchRequest)

      return fetchedResults.compactMap { model -> T? in
        let json = model.toJSON()
        if let obj: T = Mapper<T>().map(JSON: json) {
          return obj
        } else {
          return nil
        }
      }.first
    } catch {
      return nil
    }
  }
  
  func objects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate, sortBy: String?, asc: Bool?) -> [T]? {
    do {
      let entityName = String(describing: type.self)
      let fetchRequest : NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = predicate
      
      if let sortField = sortBy {
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortField, ascending: asc ?? true)]
      }
      
      return try mainContext().fetch(fetchRequest)
    } catch {
      return nil
    }
  }
  
  func firstObject<T: NSManagedObject>(type: T.Type, predicate: NSPredicate) -> T? {
    do {
      let entityName = String(describing: type.self)
      let fetchRequest : NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
      fetchRequest.predicate = predicate
      
      return try mainContext().fetch(fetchRequest).first
    } catch {
      return nil
    }
  }
}

public extension CoredataDeletable where Self: CoredataProvider {
  
  func delete<T: NSManagedObject>(_ type: T.Type, id: Any, primaryKey: String) -> Observable<Void> {
    return delete(type, ids: [id], primaryKey: primaryKey)
  }
  
  func delete<T: NSManagedObject>(_ type: T.Type, ids: [Any], primaryKey: String) -> Observable<Void> {
    return Observable<Void>.create({ [weak self] observer -> Disposable in
      
      guard let stack = self?.dataStack else {
        observer.onError(ORMError.notDefineDATAStack.error)
        return Disposables.create()
      }
      
      let op = DeleteArrayOperation<T>(ids: ids, primaryKey: primaryKey, dataStack: stack)
      op.completion = { error in
        if let existErr = error {
          observer.onError(existErr)
        } else {
          observer.onNext(())
          observer.onCompleted()
        }
      }
      
      self?.serialOperationQueue.addOperation(op)
      return Disposables.create()
    }).observeOn(ALSchedulers.shared.mainScheduler)
  }
  
}
