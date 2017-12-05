//
//  RxSchedulers.swift
//  Pulse
//
//  Created by MOPC on 09.08.16.
//  Copyright © 2016 MOPC Lab. All rights reserved.
//

import Foundation
import RxSwift

public class ALSchedulers {
  public static let shared = ALSchedulers()

  public let backgroundScheduler: ImmediateSchedulerType
  public let mainScheduler: SerialDispatchQueueScheduler

  private init() {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    operationQueue.qualityOfService = .userInitiated
    backgroundScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    mainScheduler = MainScheduler.instance
  }
}
