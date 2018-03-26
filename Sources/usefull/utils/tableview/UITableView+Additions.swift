//
//  UITableView+Additions.swift
//  ALUtilse
//
//  Created by Aleksey Lobanov on 10.10.16.
//  Copyright © 2016 Aleksey Lobanov Lab. All rights reserved.
//

import UIKit

public extension UITableView {
  typealias RegisterClass = (anyClass: AnyClass?, id: String)
  
  func setupEstimatedRowHeight(height: CGFloat? = nil) {
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = height ?? 60.0
  }

  func setupEstimatedFooterHeight(height: CGFloat? = nil) {
    sectionFooterHeight = UITableViewAutomaticDimension
    estimatedSectionFooterHeight = height ?? 40.0
  }
  
  func setupEstimatedHeaderHeight(height: CGFloat? = nil) {
    sectionHeaderHeight = UITableViewAutomaticDimension
    estimatedSectionHeaderHeight = height ?? 40.0
  }

  func registerCell(by identifier: String, bundle: Bundle? = nil) {
    register(UINib(nibName: identifier, bundle: bundle),
         forCellReuseIdentifier: identifier)
  }
  
  func registerCells(by identifiers: [String], bundle: Bundle? = nil) {
    for identifier in identifiers {
      register(UINib(nibName: identifier, bundle: bundle),
               forCellReuseIdentifier: identifier)
    }
  }
  
  func registerClass(anyClass: AnyClass?, identifier: String) {
    register(anyClass, forCellReuseIdentifier: identifier)
  }
  
  func registerClasses(anyClasses: [RegisterClass]) {
    for item in anyClasses {
      registerClass(anyClass: item.anyClass, identifier: item.id)
    }
  }
}
