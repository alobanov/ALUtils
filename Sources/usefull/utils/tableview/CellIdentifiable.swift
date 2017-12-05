//
//  CellIdentifiable.swift
//  Pulse
//
//  Created by MOPC on 09.10.16.
//  Copyright © 2016 MOPC Lab. All rights reserved.
//

import UIKit

public protocol CellIdentifiable {
  static var cellIdentifier: String { get }
}

public extension CellIdentifiable where Self: UITableViewCell {
  public static var cellIdentifier: String {
    return String(describing: self)
  }
}

extension UITableViewCell: CellIdentifiable {}

public extension UITableView {
  public func dequeueReusableTableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath, andtype:T.Type) -> T {
    guard let cell = self.dequeueReusableCell(withIdentifier: andtype.cellIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.cellIdentifier)")
    }
    
    return cell
  }
}
