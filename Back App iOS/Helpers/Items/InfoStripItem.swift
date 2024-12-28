// Copyright © 2020 Moritz Schaub. All rights reserved.
// SPDX-FileCopyrightText: 2024 Moritz Schaub <moritz@pfaender.net>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

import Foundation

class InfoStripItem: Item {
    var stepCount: Int
    var minuteCount: Int
    var ingredientCount: Int
    
    init(stepCount: Int, minuteCount: Int, ingredientCount: Int) {
        self.stepCount = stepCount
        self.minuteCount = minuteCount
        self.ingredientCount = ingredientCount
        super.init()
    }
}
