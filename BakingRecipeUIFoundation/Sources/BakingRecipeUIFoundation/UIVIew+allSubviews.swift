//
//  UIVIew+allSubviews.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import UIKit.UIView

public extension UIView {
   var allSubviews: [UIView] {
      return subviews.flatMap { [$0] + $0.allSubviews }
   }
}
