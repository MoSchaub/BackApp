//
//  ColorUtils.swift
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeStrings

enum ColorKey: String {
    case background
    case cellBackground
    case primaryText
    case primaryCellText
    case secondaryText
    case secondaryCellText
    case tint
    case separator
    case selectionCellBackground
}

public extension Color {
    static func cellBackgroundColor() -> Color {
        Color(UIColor.cellBackgroundColor)
    }
}


public extension UIColor {
    static var backgroundColor = UIColor(named: ColorKey.background.rawValue, in: .module, compatibleWith: .current)!
    static var cellBackgroundColor = UIColor(named: ColorKey.cellBackground.rawValue, in: .module, compatibleWith: .current)!
    
    static var primaryTextColor = UIColor(named: ColorKey.primaryText.rawValue, in: .module, compatibleWith: .current)!
    static var primaryCellTextColor = UIColor(named: ColorKey.primaryCellText.rawValue, in: .module, compatibleWith: .current)!
    
    static var secondaryTextColor = UIColor(named: ColorKey.primaryText.rawValue, in: .module, compatibleWith: .current)!
    static var secondaryCellTextColor = UIColor(named: ColorKey.secondaryCellText.rawValue, in: .module, compatibleWith: .current)!
    
    static var selectionCellBackgroundColor = UIColor(named: ColorKey.selectionCellBackground.rawValue, in: .module, compatibleWith: .current)!
    static var tintColor = UIColor(named: ColorKey.tint.rawValue, in: .module, compatibleWith: .current)!
}
