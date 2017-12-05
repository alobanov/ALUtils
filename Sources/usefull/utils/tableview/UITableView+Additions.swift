//
//  UITableView+Additions.swift
//  Pulse
//
//  Created by MOPC on 10.10.16.
//  Copyright © 2016 MOPC Lab. All rights reserved.
//

import UIKit

public extension UITableView {
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
}
