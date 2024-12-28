// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

//
//  Theme+Colors.swift
//  
//
//  Created by Moritz Schaub on 29.12.20.
//

import UIKit

enum ColorKey: String {
    case background
    case cellBackground
    case primaryText
    case primaryCellText
    case secondaryText
    case secondaryCellText
    case tint
    case selectedCellBackground
}

extension Theme {
    
    private func color(with key: ColorKey) -> UIColor? {
        return UIColor(named: key.rawValue, in: Bundle.module, compatibleWith: nil)
    }
    
    var backgroundColor: UIColor? {
        return color(with: .background)
    }
    
    var cellBackgroundColor: UIColor? {
        return color(with: .cellBackground)
    }
    
    var selectedCellBackground: UIColor? {
        return color(with: .selectedCellBackground)
    }
    
    var primaryTextColor: UIColor? {
        return color(with: .primaryText)
    }
    
    var primaryCellTextColor: UIColor? {
        return color(with: .primaryCellText)
    }
    
    var secondaryTextColor: UIColor? {
        return color(with: .secondaryText)
    }
    
    var secondaryCellTextColor: UIColor? {
        return color(with: .secondaryCellText)
    }
    
    var baTintColor: UIColor? {
        return color(with: .tint)
    }
    
}
