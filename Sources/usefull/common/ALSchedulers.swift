//
//  RxSchedulers.swift
//  ALUtilse
//
//  Created by Aleksey Lobanov on 09.08.16.
//  Copyright © 2016 Aleksey Lobanov Lab. All rights reserved.
//

import Foundation
import RxSwift

public class ALSchedulers {
  public static let shared = ALSchedulers()

  public let background: ImmediateSchedulerType
  public let main: SerialDispatchQueueScheduler

  private init() {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    operationQueue.qualityOfService = .userInitiated
    background = OperationQueueScheduler(operationQueue: operationQueue)
    main = MainScheduler.instance
  }
}
