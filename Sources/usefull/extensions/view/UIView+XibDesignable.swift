//
//  UIView+XibDesignable.swift
//  ALUtils
//
//  Created by Aleksey Lobanov on 05/08/2017.
//  Copyright © 2017 ALUtils. All rights reserved.
//

import UIKit

public protocol XibDesignable : class {}

public extension XibDesignable where Self : UIView {
  public static func instantiateFromXib() -> Self {
    
    let dynamicMetatype = Self.self
    let bundle = Bundle(for: dynamicMetatype)
    let nib = UINib(nibName: "\(dynamicMetatype)", bundle: bundle)
    
    guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
      fatalError("Could not load view from nib file.")
    }
    return view
  }
}

extension UIView : XibDesignable {}

public extension UIView {
  public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    self.layer.mask = mask
  }
}
