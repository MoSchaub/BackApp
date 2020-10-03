//
//  Color+cellBackgroundColor.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 16.08.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import SwiftUI
import BakingRecipeCore

extension Color {
    static func cellBackgroundColor() -> Color {
        Color(UIColor(named: Strings.backgroundColorName)!)
    }
}
