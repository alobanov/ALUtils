import RxSwift

public extension Observable where Element: Equatable {
  func ignore(_ value: Element) -> Observable<Element> {
    return filter { (e) -> Bool in
      return value != e
    }
  }
}

public protocol OptionalType {
  associatedtype Wrapped
  var value: Wrapped? { get }
}

extension Optional: OptionalType {
  public var value: Wrapped? {
    return self
  }
}

public extension ObservableType where E : Equatable {
  public func ignore(_ valuesToIgnore: E ...) -> Observable<E> {
    return self.asObservable().filter { !valuesToIgnore.contains($0) }
  }

  public func ignore<S: Sequence>(_ valuesToIgnore : S) -> Observable<E> where S.Iterator.Element == E {
    return self.asObservable().filter { !valuesToIgnore.contains($0) }
  }

  public func ignoreWhen(_ predicate: @escaping (E) throws -> Bool) -> Observable<E> {
    return self.asObservable().filter { try !predicate($0) }
  }
}

public extension Observable where Element: OptionalType {
  func filterNil() -> Observable<Element.Wrapped> {
    return flatMap { (element) -> Observable<Element.Wrapped> in
      if let value = element.value {
        return .just(value)
      } else {
        return .empty()
      }
    }
  }

  func replaceNilWith(_ nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
    return flatMap { (element) -> Observable<Element.Wrapped> in
      if let value = element.value {
        return .just(value)
      } else {
        return .just(nilValue)
      }
    }
  }
}

public extension Observable {
  func mapToVoid() -> Observable<Void> {
    return map({ _ -> Void in
      return
    })
  }
  
  func mapToType<T>(type: T.Type) -> Observable<T> {
    return map({ item -> T in
      if let item = item as? T {
        return item
      } else {
        throw NSError.define(description: "Can't cast to \(T.self) type")
      }
    })
  }
}

