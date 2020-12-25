//
//  ColorUtils.swift
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

public extension Color {
    static func cellBackgroundColor() -> Color {
        Color(UIColor.backgroundColor)
    }
}

@available(iOS 13.0, *)
public extension UIColor {
    static var backgroundColor = UIColor(named: "background", in: .module, compatibleWith: .current)!
    static var cellTextColor = UIColor(named: "cellText", in: .module, compatibleWith: .current)!
    static var secondaryColor = UIColor(named: "secondaryText", in: .module, compatibleWith: .current)!
}
