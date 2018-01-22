//
//  AsyncOperation.swift
//  ALUtils
//
//  Created by Lobanov Aleksey on 28/09/2017.
//  Copyright © 2017 ALUtils. All rights reserved.
//

import Foundation

public class AsyncOperation: Operation {
  public enum State: String {
    case ready, executing, finished
    
    fileprivate var keyPath: String {
      return "is" + rawValue.capitalized
    }
  }
  
  public var completion: ((NSError?) -> Void)?
  
  public var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }
}

public extension AsyncOperation {
  override var isReady: Bool {
    return super.isReady && state == .ready
  }
  
  override var isExecuting: Bool {
    return state == .executing
  }
  
  override var isFinished: Bool {
    return state == .finished
  }
  
  override var isAsynchronous: Bool {
    return true
  }
  
  override func start() {
    if isCancelled {
      state = .finished
      return
    }
    state = .executing
    main()
  }
  
  override func cancel() {
    state = .finished
  }
}
